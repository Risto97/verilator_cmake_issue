module apb_subsystem(
input clk,
input rstn
);
    wire   __inst__cpu_clk;
    assign __inst__cpu_clk = clk; 
    wire   __inst__cpu_rstn;
    assign __inst__cpu_rstn = rstn; 
    wire   __inst__slave0_clk;
    assign __inst__slave0_clk = clk; 
    wire   __inst__slave0_rstn;
    assign __inst__slave0_rstn = rstn; 
    wire   __inst__slave1_clk;
    assign __inst__slave1_clk = clk; 
    wire   __inst__slave1_rstn;
    assign __inst__slave1_rstn = rstn; 

    localparam N_ENDPOINTS = 2;
    localparam N_MASTERS = 1;

/*========================================================================================
*===================== Master interfaces =================================================
*========================================================================================*/
    wire [1*N_MASTERS-1:0] m_penable;
    wire [1*N_MASTERS-1:0] m_pwrite;
    wire [32*N_MASTERS-1:0] m_paddr;
    wire [1*N_MASTERS-1:0] m_psel;
    wire [32*N_MASTERS-1:0] m_pwdata;
    wire [32*N_MASTERS-1:0] m_prdata;
    wire [1*N_MASTERS-1:0] m_pready;
    wire [1*N_MASTERS-1:0] m_pslverr;
    wire [4*N_MASTERS-1:0] m_pstrb;

/*========================================================================================
*===================== Endpoint interfaces ===============================================
*========================================================================================*/
    wire [1-1:0] ep_penable;
    wire [1-1:0] ep_pwrite;
    wire [32-1:0] ep_paddr;
    wire [1*N_ENDPOINTS-1:0] ep_psel;
    wire [32-1:0] ep_pwdata;
    wire [32*N_ENDPOINTS-1:0] ep_prdata;
    wire [1*N_ENDPOINTS-1:0] ep_pready;
    wire [1*N_ENDPOINTS-1:0] ep_pslverr;
    wire [4-1:0] ep_pstrb;

/*========================================================================================
*===================== Masters instantiations ============================================
*========================================================================================*/
    apb_master #(

    ) cpu(
        .clk(__inst__cpu_clk),
        .rstn(__inst__cpu_rstn),
        .m_penable(m_penable[0 +: 1]), 
        .m_pwrite(m_pwrite[0 +: 1]), 
        .m_paddr(m_paddr[0 +: 32]), 
        .m_psel(m_psel[0 +: 1]), 
        .m_pwdata(m_pwdata[0 +: 32]), 
        .m_prdata(m_prdata[0 +: 32]), 
        .m_pready(m_pready[0 +: 1]), 
        .m_pslverr(m_pslverr[0 +: 1]), 
        .m_pstrb(m_pstrb[0 +: 4])


    );


/*========================================================================================
*===================== Interconnect instantiations =======================================
*========================================================================================*/
    apb_interconnect #(
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32),
        .N_MASTERS(N_MASTERS),
        .N_SLAVES(N_ENDPOINTS),
        .MEM_MAP( {  32'h00000400, 32'h00000800, 32'h00010000, 32'h0001fa00 } )
    ) apb_interconnect (
        // Master to interconnect slave ports
        .s_penable(m_penable),
        .s_pwrite(m_pwrite),
        .s_paddr(m_paddr),
        .s_psel(m_psel),
        .s_pwdata(m_pwdata),
        .s_prdata(m_prdata),
        .s_pready(m_pready),
        .s_pslverr(m_pslverr),
        .s_pstrb(m_pstrb),
        // Interconnect master ports to endpoints 
        .m_penable(ep_penable), 
        .m_pwrite(ep_pwrite), 
        .m_paddr(ep_paddr), 
        .m_psel(ep_psel), 
        .m_pwdata(ep_pwdata), 
        .m_prdata(ep_prdata), 
        .m_pready(ep_pready), 
        .m_pslverr(ep_pslverr), 
        .m_pstrb(ep_pstrb)

    );

/*========================================================================================
*===================== Slaves instantiations =============================================
*========================================================================================*/
    simple_apb_slave #(
        .ADDR_WIDTH(32), 
        .DATA_WIDTH(32), 
        .MEM_SIZE(1024), 
        .ID(0)

    ) slave0 (
        .clk(__inst__slave0_clk),
        .rstn(__inst__slave0_rstn),

        .s_penable(ep_penable[0 +: 1]), 
        .s_pwrite(ep_pwrite[0 +: 1]), 
        .s_paddr(ep_paddr[0 +: 32]), 
        .s_psel(ep_psel[0 +: 1]), 
        .s_pwdata(ep_pwdata[0 +: 32]), 
        .s_prdata(ep_prdata[0 +: 32]), 
        .s_pready(ep_pready[0 +: 1]), 
        .s_pslverr(ep_pslverr[0 +: 1]), 
        .s_pstrb(ep_pstrb[0 +: 4])

    );
    simple_apb_slave #(
        .ADDR_WIDTH(32), 
        .DATA_WIDTH(32), 
        .MEM_SIZE(64000), 
        .ID(1)

    ) slave1 (
        .clk(__inst__slave1_clk),
        .rstn(__inst__slave1_rstn),

        .s_penable(ep_penable[0 +: 1]), 
        .s_pwrite(ep_pwrite[0 +: 1]), 
        .s_paddr(ep_paddr[0 +: 32]), 
        .s_psel(ep_psel[1 +: 1]), 
        .s_pwdata(ep_pwdata[0 +: 32]), 
        .s_prdata(ep_prdata[32 +: 32]), 
        .s_pready(ep_pready[1 +: 1]), 
        .s_pslverr(ep_pslverr[1 +: 1]), 
        .s_pstrb(ep_pstrb[0 +: 4])

    );

/*========================================================================================
*===================== Adapters instantiation ============================================
*========================================================================================*/
/*========================================================================================
*===================== Subsystems instantiations =========================================
*========================================================================================*/


endmodule
