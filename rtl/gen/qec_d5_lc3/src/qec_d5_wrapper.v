`timescale 1 ns / 1 ps

module qec_d5_wrapper (
   input clk,
    // verilator lint_off UNUSEDSIGNAL
    input [599:0] model_inp,
    // verilator lint_on UNUSEDSIGNAL
    output [21:0] model_out
);
    wire [530:0] packed_inp;
    wire [21:0] packed_out;

    assign packed_inp[3:0] = model_inp[4:1];
    assign packed_inp[12:4] = model_inp[14:6];
    assign packed_inp[21:13] = model_inp[24:16];
    assign packed_inp[40:22] = model_inp[44:26];
    assign packed_inp[44:41] = model_inp[49:46];
    assign packed_inp[48:45] = model_inp[54:51];
    assign packed_inp[52:49] = model_inp[59:56];
    assign packed_inp[56:53] = model_inp[64:61];
    assign packed_inp[65:57] = model_inp[74:66];
    assign packed_inp[74:66] = model_inp[84:76];
    assign packed_inp[83:75] = model_inp[94:86];
    assign packed_inp[87:84] = model_inp[99:96];
    assign packed_inp[106:88] = model_inp[119:101];
    assign packed_inp[120:107] = model_inp[134:121];
    assign packed_inp[124:121] = model_inp[139:136];
    assign packed_inp[128:125] = model_inp[144:141];
    assign packed_inp[132:129] = model_inp[149:146];
    assign packed_inp[136:133] = model_inp[154:151];
    assign packed_inp[140:137] = model_inp[159:156];
    assign packed_inp[144:141] = model_inp[164:161];
    assign packed_inp[148:145] = model_inp[169:166];
    assign packed_inp[157:149] = model_inp[179:171];
    assign packed_inp[171:158] = model_inp[194:181];
    assign packed_inp[180:172] = model_inp[204:196];
    assign packed_inp[189:181] = model_inp[214:206];
    assign packed_inp[193:190] = model_inp[219:216];
    assign packed_inp[202:194] = model_inp[229:221];
    assign packed_inp[211:203] = model_inp[239:231];
    assign packed_inp[215:212] = model_inp[244:241];
    assign packed_inp[224:216] = model_inp[254:246];
    assign packed_inp[228:225] = model_inp[259:256];
    assign packed_inp[232:229] = model_inp[264:261];
    assign packed_inp[236:233] = model_inp[269:266];
    assign packed_inp[240:237] = model_inp[274:271];
    assign packed_inp[244:241] = model_inp[279:276];
    assign packed_inp[248:245] = model_inp[284:281];
    assign packed_inp[257:249] = model_inp[294:286];
    assign packed_inp[261:258] = model_inp[299:296];
    assign packed_inp[275:262] = model_inp[314:301];
    assign packed_inp[284:276] = model_inp[324:316];
    assign packed_inp[308:285] = model_inp[349:326];
    assign packed_inp[332:309] = model_inp[374:351];
    assign packed_inp[336:333] = model_inp[379:376];
    assign packed_inp[340:337] = model_inp[384:381];
    assign packed_inp[344:341] = model_inp[389:386];
    assign packed_inp[348:345] = model_inp[394:391];
    assign packed_inp[352:349] = model_inp[399:396];
    assign packed_inp[356:353] = model_inp[404:401];
    assign packed_inp[365:357] = model_inp[414:406];
    assign packed_inp[369:366] = model_inp[419:416];
    assign packed_inp[373:370] = model_inp[424:421];
    assign packed_inp[392:374] = model_inp[444:426];
    assign packed_inp[406:393] = model_inp[459:446];
    assign packed_inp[430:407] = model_inp[484:461];
    assign packed_inp[439:431] = model_inp[494:486];
    assign packed_inp[443:440] = model_inp[499:496];
    assign packed_inp[447:444] = model_inp[504:501];
    assign packed_inp[451:448] = model_inp[509:506];
    assign packed_inp[455:452] = model_inp[514:511];
    assign packed_inp[459:456] = model_inp[519:516];
    assign packed_inp[463:460] = model_inp[524:521];
    assign packed_inp[472:464] = model_inp[534:526];
    assign packed_inp[481:473] = model_inp[544:536];
    assign packed_inp[500:482] = model_inp[564:546];
    assign packed_inp[509:501] = model_inp[574:566];
    assign packed_inp[518:510] = model_inp[584:576];
    assign packed_inp[522:519] = model_inp[589:586];
    assign packed_inp[526:523] = model_inp[594:591];
    assign packed_inp[530:527] = model_inp[599:596];

    qec_d5 op (
        .clk(clk),
        .model_inp(packed_inp),
        .model_out(packed_out)
    );

    assign model_out[21:0] = packed_out[21:0];

endmodule
