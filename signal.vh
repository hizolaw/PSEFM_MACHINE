`ifndef __SIGNAL_HEADER__
    `define __SIGNAL_HEADER__

    `define RESET_EDGE      posedge
    `define RESET_EDGE_     negedge

    `define RESET_ENABLE    1'b1
    `define RESET_DISABLE   1'b0

    `define HIGH            1'b1
    `define ENABLE          1'b1
    `define ENABLE_         1'b0
    `define LOW             1'b0
    `define DISABLE         1'b0
    `define DISABLE_        1'b1

    `define WRITE           1'b1
    `define READ            1'b0

`endif
