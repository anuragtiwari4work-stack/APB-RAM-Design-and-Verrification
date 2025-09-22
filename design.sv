module apb_s
(
    input        pclk,
    input        presetn,
    input  [31:0] paddr,
    input        psel,
    input        penable,
    input  [7:0] pwdata,
    input        pwrite,

    output reg [7:0] prdata,
    output reg       pready,
    output           pslverr
);

    localparam [1:0] IDLE  = 2'd0,
                     WRITE = 2'd1,
                     READ  = 2'd2;

    reg [7:0] mem [0:15];

    reg [1:0] state, nstate;

    bit addr_err, addv_err, data_err;

    // state register
    always @(posedge pclk or negedge presetn) begin
        if (!presetn)
            state <= IDLE;
        else
            state <= nstate;
    end

    // next-state and output logic
    always @(*) begin
        case (state)
            IDLE: begin
                prdata = 8'h00;
                pready = 1'b0;

                if (psel &&  pwrite)  nstate = WRITE;
                else if (psel && !pwrite) nstate = READ;
                else nstate = IDLE;
            end

            WRITE: begin
                if (psel && penable) begin
                    if (!addr_err && !addv_err && !data_err) begin
                        pready      = 1'b1;
                        mem[paddr]  = pwdata;
                        nstate      = IDLE;
                    end else begin
                        pready = 1'b1;
                        nstate = IDLE;
                    end
                end
            end

            READ: begin
                if (psel && penable) begin
                    if (!addr_err && !addv_err && !data_err) begin
                        pready = 1'b1;
                        prdata = mem[paddr];
                        nstate = IDLE;
                    end else begin
                        pready = 1'b1;
                        prdata = 8'h00;
                        nstate = IDLE;
                    end
                end
            end

            default: begin
                nstate = IDLE;
                prdata = 8'h00;
                pready = 1'b0;
            end
        endcase
    end

    // simple validity checks
    reg av_t;
    always @(*) begin
        av_t = (paddr >= 0) ? 1'b0 : 1'b1;
    end

    reg dv_t;
    always @(*) begin
        dv_t = (pwdata >= 0) ? 1'b0 : 1'b1;
    end

    assign addr_err = ((nstate == WRITE || nstate == READ) && (paddr > 15)) ? 1'b1 : 1'b0;
    assign addv_err = (nstate == WRITE || nstate == READ) ? av_t : 1'b0;
    assign data_err = (nstate == WRITE || nstate == READ) ? dv_t : 1'b0;

    assign pslverr  = (psel && penable) ? (addv_err || addr_err || data_err) : 1'b0;

endmodule
