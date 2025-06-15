//comparator
module comparator(
    input logic address1,
    input logic address2,
    output logic compare_bar
);
always_comb
begin
    if(address1 != address2)
        compare_bar = 1;
    else
        compare_bar = 0;
end
endmodule