// arhitectura unei celule full adder cell cu porti AND, OR si XOR
module fac(input x, y, cin,
  output z, cout);

assign z=x^y^cin;
assign cout=(x&y)|(x&cin)|(y&cin);



endmodule


// arhitectura unui sumator pe 4 biti care foloseste celula full adder creata anterior
module fac_4bits(
input [3:0]x, y,
input cin,// Carry poate veni de la o tetrad? precedent? 
output[3:0]z, //  rezultatul însum?rii celor 4 biti
output cout); 

 wire c[4:0];
 // se vor instantia secvential celule FAC cu care se va realiza suma celor 4 biti
 // se foloseste un fir care retine carry out-ul din fiecare instanta a sumatorului si il foloseste la urmatoarea instanta
 genvar i;
 generate for(i=0;i<4;i=i+1)begin
   fac this_fac(x[i], y[i], c[i], z[i], c[i+1]);
 end
 endgenerate
 
 assign c[0]=cin;// primul carry din suma unei tetrade va trebui sa fie legat la inputul din tetrada precedenta
 assign cout=c[4]; // carry ul sumei celor 4 biti va fi egal cu ultima valoare din firul de carry

endmodule

module sum_1bcd(
  input [3:0]x, y,
  input cin,
  output [3:0]z,
  output cout);
  
  wire g,cor;
  wire [3:0] intermediar,corectie;
  // folosim doua fire aditionale care pentru a "creea" nivele de insumare

  
  // in firul intermediar se retine suma rezultata inainte de corectia BCD
  fac_4bits this_fac(x, y, cin, intermediar, g);
  
  /*corectia va fi egala cu 6 ( binar :0110) care se insumeaza la rezultatul obtinut anterior pentru convertirea tetradei in BCD
  corectia se aplica in cazul in care suma este mai mare sau egala cu 10 deoarece in cazul celor 4 biti a aduna 6 la suma initiala
  este echivalentul impartirii cu 10 a rezultatului  */
  assign cor=g|(intermediar[3]&intermediar[2])|(intermediar[3]&intermediar[1]);// se creaza corectia bazata pe regula mentionata mai sus
  assign corectie={1'b0,cor,cor,1'b0};
  fac_4bits this_fac2(intermediar, corectie, 1'b0,  z); // se aplica corectia si se obtine rezultatul final
  
  assign cout=cor; 
  
  
  
endmodule

// sumatorul BCD pe w - biti
module BCD #(parameter w=2)(
  input [4*w-1:0]x,y,
  output [4*(w+1)-1:0]z);// carry out-ul va avea w+1 tetrade in cazul unui carry out aditional care va mari dimensiunea cu o tetrada fata de inputul initial
  
  wire [w:0]g;// fir legat la carry out-ul din ficare tetrada
  wire [4*w-1:0] intermediar;
  genvar i;
  generate for(i=0;i<w;i=i+1)begin:vect
    sum_1bcd this_bcd(x[i*4+3:i*4], y[i*4+3:i*4], g[i], intermediar[i*4+3:i*4], g[i+1]);
    // insumarea a cate 4 biti din inputul initial folosind sumatorul BCD creat anterior 
  end
endgenerate
  
  assign g[0]=0;// carry out-ul initial va fi 0 deoarece la prima tetrada nu avem un carry in
  assign z={g[w],intermediar}; // rezultatul va fi format din concatenarea ultimului carry si rezultatul intermediar
endmodule

// BOUNDARY TEST
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