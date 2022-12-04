module fac(input x, y, cin,
  output z, cout);

assign z=x^y^cin;
assign cout=(x&y)|(x&cin)|(y&cin);



endmodule

module fac_4bits(
input [3:0]x, y,
input cin,
output[3:0]z,
output cout);

 wire c[4:0];
 genvar i;
 generate for(i=0;i<4;i=i+1)begin
   fac this_fac(x[i], y[i], c[i], z[i], c[i+1]);
 end
 endgenerate
 
 assign c[0]=cin;
 assign cout=c[4];

endmodule

module sum_1bcd(
  input [3:0]x, y,
  input cin,
  output [3:0]z,
  output cout);
  
  wire g,cor;
  wire [3:0] intermediar,corectie;
  
  fac_4bits this_fac(x, y, cin, intermediar, g);
  
  assign cor=g|(intermediar[3]&intermediar[2])|(intermediar[3]&intermediar[1]);
  assign corectie={1'b0,cor,cor,1'b0};
  fac_4bits this_fac2(intermediar, corectie, 1'b0,  z);
  
  assign cout=cor;
  
  
  
endmodule

module BCD #(parameter w=2)(
  input [4*w-1:0]x,y,
  output [4*(w+1)-1:0]z);
  
  wire [w:0]g;
  wire [4*w-1:0] intermediar;
  genvar i;
  generate for(i=0;i<w;i=i+1)begin:vect
    sum_1bcd this_bcd(x[i*4+3:i*4], y[i*4+3:i*4], g[i], intermediar[i*4+3:i*4], g[i+1]);
  end
endgenerate
  
  assign g[0]=0;
  assign z={g[w],intermediar};
endmodule

module sum_BCD_tb;
  
  
  reg[11:0]x, y;
  reg cin;
  wire [15:0]z;

  
  BCD #(3) uut(x, y, z);
  
  initial begin
    
    $display("X\t Y\t Z\t");
    $monitor("x=%b\t y=%b\t z=%b\t",x, y, z);
   x=12'd0;
   y=12'd0;
   
   #20;
   x=12'b000101000011;
   y=12'b001000100000;
   
   #20;
   x=12'b100000010111;
   y=12'b010100100011;
   
   #20;
   x=12'b100110011001;
   y=12'b100110011001;
    
  end
  
endmodule