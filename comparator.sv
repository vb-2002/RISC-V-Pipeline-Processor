//comparator
module comparator(
    input logic address1,
    input logic address2,
    output logic compare_bar
);

assign compare_bar = (address1 != address2);

endmodule