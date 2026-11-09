// mask[3:0] = { 4'b1000 - 30b mask,4'b0100 - 31b mask, 4'b0010 - 28b mask, 4'b0001 - 32b mask }
always_comb begin
  case (address[14:0])
    15'b011000000000000 : mask[3:0] = 4'b0100;
    15'b100000000000100 : mask[3:0] = 4'b1000;
    15'b010000000000100 : mask[3:0] = 4'b0100;
    15'b000000000000100 : mask[3:0] = 4'b0010;
    default           : mask[3:0] = 4'b0001;
  endcase
end
