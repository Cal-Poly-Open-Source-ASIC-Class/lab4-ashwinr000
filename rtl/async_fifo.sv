module async_fifo #(parameter WIDTH=8, parameter DEPTH=8) (
        input rst,
        input w_clk,
        input w_en,
        input [(WIDTH-1):0] w_data,
        input r_clk,
        input r_en,
        //output logic [$clog2(DEPTH)-1:0] w_ptr_gray,
        //output logic [$clog2(DEPTH)-1:0] r_ptr_gray,
        //output logic [$clog2(DEPTH)-1:0] w_ptr_gray_r2,
        //output logic [$clog2(DEPTH)-1:0] r_ptr_gray_w2,
        output logic [(WIDTH-1):0] r_data,
        output logic w_full,
        output logic r_empty
    );

    logic [(WIDTH-1):0] fifo[0:(DEPTH-1)];
    logic [$clog2(DEPTH)-1:0] w_ptr;
    logic [$clog2(DEPTH)-1:0] r_ptr;

    logic [$clog2(DEPTH)-1:0] w_ptr_gray;
    logic [$clog2(DEPTH)-1:0] r_ptr_gray;

    logic [$clog2(DEPTH)-1:0] w_ptr_gray_r1;
    logic [$clog2(DEPTH)-1:0] r_ptr_gray_w1;
    
    logic [$clog2(DEPTH)-1:0] w_ptr_gray_r2;
    logic [$clog2(DEPTH)-1:0] r_ptr_gray_w2;

    assign r_ptr_gray = r_ptr ^ (r_ptr >> 1);
    assign w_ptr_gray = w_ptr ^ (w_ptr >> 1);

    assign w_full = (w_ptr_gray[$clog2(DEPTH)-1:$clog2(DEPTH)-2] == ~r_ptr_gray_w2[$clog2(DEPTH)-1:$clog2(DEPTH)-2])
				&& (w_ptr_gray[$clog2(DEPTH)-3:0] == r_ptr_gray_w2[$clog2(DEPTH)-3:0]);
    assign r_empty = (w_ptr_gray_r2 == r_ptr_gray);

    always @(posedge w_clk or posedge rst)
    begin
        if (rst)
        begin
            w_ptr <= 0;
            r_ptr_gray_w1 <= 0;
            r_ptr_gray_w2 <= 0;
        end
        else
        begin
            if (w_en & ~w_full)
            begin
                fifo[w_ptr] <= w_data;
                w_ptr <= w_ptr + 1;
            end
            else
            begin
                fifo[w_ptr] <= fifo[w_ptr];
                w_ptr <= w_ptr;
            end
            r_ptr_gray_w2 <= r_ptr_gray_w1;
            r_ptr_gray_w1 <= r_ptr_gray;
        end
        //r_empty <= (w_ptr_gray_r2 == r_ptr_gray);
    end

    always @(posedge r_clk or posedge rst)
    begin
        if (rst)
        begin
            r_ptr <= 0;
            w_ptr_gray_r1 <= 0;
            w_ptr_gray_r2 <= 0;
        end 
        else
        begin
            if (r_en & ~r_empty)
            begin
                r_data <= fifo[r_ptr];
                r_ptr <= r_ptr + 1;
            end
            else
            begin
                r_data <= r_data;
                r_ptr <= r_ptr;
            end
            w_ptr_gray_r2 <= w_ptr_gray_r1;
            w_ptr_gray_r1 <= w_ptr_gray;
            //w_full <= (w_ptr_gray[$clog2(DEPTH)-1:$clog2(DEPTH)-2] == ~r_ptr_gray_w2[$clog2(DEPTH)-1:$clog2(DEPTH)-2])
            //		&& (w_ptr_gray[$clog2(DEPTH)-3:0] == r_ptr_gray_w2[$clog2(DEPTH)-3:0]);
        end
    end


endmodule