function(verilate TARGET)
    set(OPTIONS "COVERAGE;TRACE;TRACE_FST;SYSTEMC;TRACE_STRUCTS;EXCLUDE_FROM_ALL")
    set(ONE_PARAM_ARGS "PREFIX;TOP_MODULE;THREADS;TRACE_THREADS;DIRECTORY")
    set(MULTI_PARAM_ARGS "SOURCES;VERILATOR_ARGS;INCLUDE_DIRS;OPT_SLOW;OPT_FAST;OPT_GLOBAL")
    cmake_parse_arguments(VERILATE "${OPTIONS}"
        "${ONE_PARAM_ARGS}"
        "${MULTI_PARAM_ARGS}"
        ${ARGN})


    if (NOT VERILATE_SOURCES)
        message(FATAL_ERROR "Need at least one source")
    endif()

    if(NOT VERILATE_TOP_MODULE)
        list(GET VERILATE_SOURCES 0 FIRST_SOURCE)
        get_filename_component(TOP_MODULE ${FIRST_SOURCE} NAME_WE)
    else()
        set(TOP_MODULE ${VERILATE_TOP_MODULE})
    endif()

    if(VERILATE_EXCLUDE_FROM_ALL)
        set(VERILATE_EXCLUDE_FROM_ALL "EXCLUDE_FROM_ALL")
    else()
        set(VERILATE_EXCLUDE_FROM_ALL "")
    endif()

    set(MAIN_FN "V${TOP_MODULE}__main.cpp")
    if(VERILATE_PREFIX)
        set(TOP_MODULE ${VERILATE_PREFIX})
        set(MAIN_FN "${TOP_MODULE}__main.cpp")
    else()
        if(VERILATE_TOP_MODULE)
            set(VERILATE_PREFIX "V${VERILATE_TOP_MODULE}")
            message("VERILATE_PREFIX: ${VERILATE_TOP_MODULE}")
        endif()
    endif()

    if(NOT VERILATE_DIRECTORY)
        set(VERILATE_DIRECTORY "${PROJECT_BINARY_DIR}/${TARGET}_vlt/verilate")
    endif()

    list(FIND VERILATE_VERILATOR_ARGS --main GENERATE_MAIN)

    if(GENERATE_MAIN GREATER -1)
        set(MAIN "${VERILATE_DIRECTORY}/${MAIN_FN}")
        set_source_files_properties(${MAIN} PROPERTIES GENERATED TRUE)

        if(NOT TARGET ${TARGET})
            file(WRITE "${PROJECT_BINARY_DIR}/__null.cpp" "")
            add_executable(${TARGET} ${VERILATE_EXCLUDE_FROM_ALL}
                "${PROJECT_BINARY_DIR}/__null.cpp"
                )
        endif()

        target_sources(${TARGET} PUBLIC
            ${MAIN}
            )
    endif()

    foreach(param ${MULTI_PARAM_ARGS})
        string(REPLACE ";" "|" VERILATE_${param} "${VERILATE_${param}}")
    endforeach()

    foreach(param ${OPTIONS} ${ONE_PARAM_ARGS} ${MULTI_PARAM_ARGS})
        if(VERILATE_${param})
            list(APPEND EXT_PRJ_ARGS "-DVERILATE_${param}=${VERILATE_${param}}")
            list(APPEND ARGUMENTS_LIST ${param})
        endif()
    endforeach()
    string(REPLACE ";" "|" ARGUMENTS_LIST "${ARGUMENTS_LIST}")

    if(CMAKE_CXX_STANDARD)
        set(ARG_CMAKE_CXX_STANDARD "-DCMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD}")
    endif()

    set(VERILATOR_HOME /mnt/ext/verisc/open/verilator-5.006/)
      include(ExternalProject)
      ExternalProject_Add(${TARGET}_vlt
          DOWNLOAD_COMMAND ""
          SOURCE_DIR "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/verilator"
          PREFIX ${PROJECT_BINARY_DIR}/${TARGET}_vlt
          BINARY_DIR ${PROJECT_BINARY_DIR}/${TARGET}_vlt
          LIST_SEPARATOR |
          BUILD_ALWAYS 1

          CMAKE_ARGS
              ${ARG_CMAKE_CXX_STANDARD}
              -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
              -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
              -DCMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}

              -DTARGET=${TARGET}
              -DARGUMENTS_LIST=${ARGUMENTS_LIST}
              ${EXT_PRJ_ARGS}
              -DVERILATOR_ROOT=${VERILATOR_HOME}

          INSTALL_COMMAND ""
          DEPENDS ${RTL_LIB}
          EXCLUDE_FROM_ALL 1
          ) 

    set(VLT_STATIC_LIB "${PROJECT_BINARY_DIR}/${TARGET}_vlt/lib${TARGET}.a")
    set(INC_DIR ${VERILATE_DIRECTORY})
    
    add_library(tmp_${TOP_MODULE} STATIC IMPORTED)
    add_dependencies(${TARGET} tmp_${TOP_MODULE} ${TARGET}_vlt)
    set_target_properties(tmp_${TOP_MODULE} PROPERTIES IMPORTED_LOCATION ${VLT_STATIC_LIB})
    
    target_include_directories(${TARGET} PRIVATE ${INC_DIR})
    target_include_directories(${TARGET} PRIVATE
        "${VERILATOR_HOME}/include"
        "${VERILATOR_HOME}/include/vltstd")

    set(THREADS_PREFER_PTHREAD_FLAG ON)
    find_package(Threads REQUIRED)

    target_link_libraries(${TARGET} PRIVATE tmp_${TOP_MODULE} -pthread)
    #
endfunction()


