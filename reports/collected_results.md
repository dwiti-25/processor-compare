# Collected processor comparison results

Generated from the tool reports and simulation logs under `results/raw/` by `scripts/collect.py`.
All performance, area, timing, and power values below are taken from the local project results.

## RTL simulation summary

| Core | Config | Tests passed | CoreMark/MHz | Dhrystone cycles/run | DMIPS/MHz |
|---|---|---:|---:|---:|---:|
| Hazard3 | default | 52/52 | 2.753 | 528.1 | 1.078 |
| Ibex | small | 52/52 | 2.23 | 687.1 | 0.828 |
| VeeR EL2 | min | 52/52 | 0.808 | 1699.3 | 0.335 |
| VeeR EL2 | tcm | 51/52 | 3.072 | 454.1 | 1.253 |

### Per-benchmark RTL simulation results

Cycle counts are from the shared Verilator testbench. `marked_cycles` is the measured benchmark window; it is zero for tests without a benchmark marker.

| Core | Config | Benchmark | Exit | Total cycles | Marked cycles | Iterations | CoreMark/MHz | Dhrystone cycles/run | DMIPS/MHz | Log |
|---|---|---|---|---|---|---|---|---|---|---|
| Hazard3 | default | coremark | 0 | 3664004 | 3632492 | 10 | 2.753 | — | — | results/raw/sim/hazard3_default/coremark.log |
| Hazard3 | default | dhrystone | 0 | 285045 | 264034 | 500 | — | 528.1 | 1.078 | results/raw/sim/hazard3_default/dhrystone.log |
| Hazard3 | default | hello | 0 | 5355 | 0 | — | — | — | — | results/raw/sim/hazard3_default/hello.log |
| Hazard3 | default | rv32uc-rvc | 0 | 217 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32uc-rvc.log |
| Hazard3 | default | rv32ui-add | 0 | 455 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-add.log |
| Hazard3 | default | rv32ui-addi | 0 | 223 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-addi.log |
| Hazard3 | default | rv32ui-and | 0 | 482 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-and.log |
| Hazard3 | default | rv32ui-andi | 0 | 183 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-andi.log |
| Hazard3 | default | rv32ui-auipc | 0 | 37 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-auipc.log |
| Hazard3 | default | rv32ui-beq | 0 | 297 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-beq.log |
| Hazard3 | default | rv32ui-bge | 0 | 327 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-bge.log |
| Hazard3 | default | rv32ui-bgeu | 0 | 356 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-bgeu.log |
| Hazard3 | default | rv32ui-blt | 0 | 297 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-blt.log |
| Hazard3 | default | rv32ui-bltu | 0 | 330 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-bltu.log |
| Hazard3 | default | rv32ui-bne | 0 | 300 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-bne.log |
| Hazard3 | default | rv32ui-jal | 0 | 33 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-jal.log |
| Hazard3 | default | rv32ui-jalr | 0 | 104 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-jalr.log |
| Hazard3 | default | rv32ui-lb | 0 | 238 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-lb.log |
| Hazard3 | default | rv32ui-lbu | 0 | 237 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-lbu.log |
| Hazard3 | default | rv32ui-ld_st | 0 | 1179 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-ld_st.log |
| Hazard3 | default | rv32ui-lh | 0 | 256 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-lh.log |
| Hazard3 | default | rv32ui-lhu | 0 | 265 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-lhu.log |
| Hazard3 | default | rv32ui-lui | 0 | 41 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-lui.log |
| Hazard3 | default | rv32ui-lw | 0 | 270 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-lw.log |
| Hazard3 | default | rv32ui-or | 0 | 489 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-or.log |
| Hazard3 | default | rv32ui-ori | 0 | 190 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-ori.log |
| Hazard3 | default | rv32ui-sb | 0 | 478 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-sb.log |
| Hazard3 | default | rv32ui-sh | 0 | 533 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-sh.log |
| Hazard3 | default | rv32ui-simple | 0 | 15 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-simple.log |
| Hazard3 | default | rv32ui-sll | 0 | 484 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-sll.log |
| Hazard3 | default | rv32ui-slli | 0 | 223 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-slli.log |
| Hazard3 | default | rv32ui-slt | 0 | 449 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-slt.log |
| Hazard3 | default | rv32ui-slti | 0 | 219 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-slti.log |
| Hazard3 | default | rv32ui-sltiu | 0 | 219 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-sltiu.log |
| Hazard3 | default | rv32ui-sltu | 0 | 449 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-sltu.log |
| Hazard3 | default | rv32ui-sra | 0 | 505 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-sra.log |
| Hazard3 | default | rv32ui-srai | 0 | 242 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-srai.log |
| Hazard3 | default | rv32ui-srl | 0 | 502 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-srl.log |
| Hazard3 | default | rv32ui-srli | 0 | 235 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-srli.log |
| Hazard3 | default | rv32ui-st_ld | 0 | 507 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-st_ld.log |
| Hazard3 | default | rv32ui-sub | 0 | 447 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-sub.log |
| Hazard3 | default | rv32ui-sw | 0 | 540 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-sw.log |
| Hazard3 | default | rv32ui-xor | 0 | 485 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-xor.log |
| Hazard3 | default | rv32ui-xori | 0 | 191 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32ui-xori.log |
| Hazard3 | default | rv32um-div | 0 | 382 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32um-div.log |
| Hazard3 | default | rv32um-divu | 0 | 378 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32um-divu.log |
| Hazard3 | default | rv32um-mul | 0 | 451 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32um-mul.log |
| Hazard3 | default | rv32um-mulh | 0 | 2094 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32um-mulh.log |
| Hazard3 | default | rv32um-mulhsu | 0 | 2092 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32um-mulhsu.log |
| Hazard3 | default | rv32um-mulhu | 0 | 2074 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32um-mulhu.log |
| Hazard3 | default | rv32um-rem | 0 | 382 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32um-rem.log |
| Hazard3 | default | rv32um-remu | 0 | 377 | 0 | — | — | — | — | results/raw/sim/hazard3_default/rv32um-remu.log |
| Ibex | small | coremark | 0 | 4524383 | 4484990 | 10 | 2.23 | — | — | results/raw/sim/ibex_default/coremark.log |
| Ibex | small | dhrystone | 0 | 368219 | 343540 | 500 | — | 687.1 | 0.828 | results/raw/sim/ibex_default/dhrystone.log |
| Ibex | small | hello | 0 | 5922 | 0 | — | — | — | — | results/raw/sim/ibex_default/hello.log |
| Ibex | small | rv32uc-rvc | 0 | 224 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32uc-rvc.log |
| Ibex | small | rv32ui-add | 0 | 473 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-add.log |
| Ibex | small | rv32ui-addi | 0 | 232 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-addi.log |
| Ibex | small | rv32ui-and | 0 | 500 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-and.log |
| Ibex | small | rv32ui-andi | 0 | 192 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-andi.log |
| Ibex | small | rv32ui-auipc | 0 | 40 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-auipc.log |
| Ibex | small | rv32ui-beq | 0 | 326 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-beq.log |
| Ibex | small | rv32ui-bge | 0 | 365 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-bge.log |
| Ibex | small | rv32ui-bgeu | 0 | 394 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-bgeu.log |
| Ibex | small | rv32ui-blt | 0 | 326 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-blt.log |
| Ibex | small | rv32ui-bltu | 0 | 359 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-bltu.log |
| Ibex | small | rv32ui-bne | 0 | 331 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-bne.log |
| Ibex | small | rv32ui-jal | 0 | 36 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-jal.log |
| Ibex | small | rv32ui-jalr | 0 | 110 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-jalr.log |
| Ibex | small | rv32ui-lb | 0 | 269 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-lb.log |
| Ibex | small | rv32ui-lbu | 0 | 268 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-lbu.log |
| Ibex | small | rv32ui-ld_st | 0 | 1328 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-ld_st.log |
| Ibex | small | rv32ui-lh | 0 | 287 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-lh.log |
| Ibex | small | rv32ui-lhu | 0 | 296 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-lhu.log |
| Ibex | small | rv32ui-lui | 0 | 44 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-lui.log |
| Ibex | small | rv32ui-lw | 0 | 301 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-lw.log |
| Ibex | small | rv32ui-or | 0 | 507 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-or.log |
| Ibex | small | rv32ui-ori | 0 | 199 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-ori.log |
| Ibex | small | rv32ui-sb | 0 | 537 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-sb.log |
| Ibex | small | rv32ui-sh | 0 | 592 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-sh.log |
| Ibex | small | rv32ui-simple | 0 | 17 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-simple.log |
| Ibex | small | rv32ui-sll | 0 | 502 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-sll.log |
| Ibex | small | rv32ui-slli | 0 | 232 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-slli.log |
| Ibex | small | rv32ui-slt | 0 | 467 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-slt.log |
| Ibex | small | rv32ui-slti | 0 | 228 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-slti.log |
| Ibex | small | rv32ui-sltiu | 0 | 228 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-sltiu.log |
| Ibex | small | rv32ui-sltu | 0 | 467 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-sltu.log |
| Ibex | small | rv32ui-sra | 0 | 523 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-sra.log |
| Ibex | small | rv32ui-srai | 0 | 251 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-srai.log |
| Ibex | small | rv32ui-srl | 0 | 520 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-srl.log |
| Ibex | small | rv32ui-srli | 0 | 244 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-srli.log |
| Ibex | small | rv32ui-st_ld | 0 | 560 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-st_ld.log |
| Ibex | small | rv32ui-sub | 0 | 465 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-sub.log |
| Ibex | small | rv32ui-sw | 0 | 598 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-sw.log |
| Ibex | small | rv32ui-xor | 0 | 503 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-xor.log |
| Ibex | small | rv32ui-xori | 0 | 200 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32ui-xori.log |
| Ibex | small | rv32um-div | 0 | 293 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32um-div.log |
| Ibex | small | rv32um-divu | 0 | 294 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32um-divu.log |
| Ibex | small | rv32um-mul | 0 | 569 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32um-mul.log |
| Ibex | small | rv32um-mulh | 0 | 622 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32um-mulh.log |
| Ibex | small | rv32um-mulhsu | 0 | 622 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32um-mulhsu.log |
| Ibex | small | rv32um-mulhu | 0 | 622 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32um-mulhu.log |
| Ibex | small | rv32um-rem | 0 | 293 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32um-rem.log |
| Ibex | small | rv32um-remu | 0 | 293 | 0 | — | — | — | — | results/raw/sim/ibex_default/rv32um-remu.log |
| VeeR EL2 | min | coremark | 0 | 12471790 | 12369671 | 10 | 0.808 | — | — | results/raw/sim/veer_el2_min/coremark.log |
| VeeR EL2 | min | dhrystone | 0 | 912372 | 849645 | 500 | — | 1699.3 | 0.335 | results/raw/sim/veer_el2_min/dhrystone.log |
| VeeR EL2 | min | hello | 0 | 6009 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/hello.log |
| VeeR EL2 | min | rv32uc-rvc | 0 | 889 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32uc-rvc.log |
| VeeR EL2 | min | rv32ui-add | 0 | 1647 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-add.log |
| VeeR EL2 | min | rv32ui-addi | 0 | 870 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-addi.log |
| VeeR EL2 | min | rv32ui-and | 0 | 2047 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-and.log |
| VeeR EL2 | min | rv32ui-andi | 0 | 734 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-andi.log |
| VeeR EL2 | min | rv32ui-auipc | 0 | 154 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-auipc.log |
| VeeR EL2 | min | rv32ui-beq | 0 | 994 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-beq.log |
| VeeR EL2 | min | rv32ui-bge | 0 | 1092 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-bge.log |
| VeeR EL2 | min | rv32ui-bgeu | 0 | 1299 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-bgeu.log |
| VeeR EL2 | min | rv32ui-blt | 0 | 994 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-blt.log |
| VeeR EL2 | min | rv32ui-bltu | 0 | 1216 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-bltu.log |
| VeeR EL2 | min | rv32ui-bne | 0 | 990 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-bne.log |
| VeeR EL2 | min | rv32ui-jal | 0 | 133 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-jal.log |
| VeeR EL2 | min | rv32ui-jalr | 0 | 428 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-jalr.log |
| VeeR EL2 | min | rv32ui-lb | 0 | 977 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-lb.log |
| VeeR EL2 | min | rv32ui-lbu | 0 | 993 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-lbu.log |
| VeeR EL2 | min | rv32ui-ld_st | 0 | 4521 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-ld_st.log |
| VeeR EL2 | min | rv32ui-lh | 0 | 1045 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-lh.log |
| VeeR EL2 | min | rv32ui-lhu | 0 | 1078 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-lhu.log |
| VeeR EL2 | min | rv32ui-lui | 0 | 187 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-lui.log |
| VeeR EL2 | min | rv32ui-lw | 0 | 1125 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-lw.log |
| VeeR EL2 | min | rv32ui-or | 0 | 2059 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-or.log |
| VeeR EL2 | min | rv32ui-ori | 0 | 774 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-ori.log |
| VeeR EL2 | min | rv32ui-sb | 0 | 1981 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-sb.log |
| VeeR EL2 | min | rv32ui-sh | 0 | 2150 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-sh.log |
| VeeR EL2 | min | rv32ui-simple | 0 | 72 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-simple.log |
| VeeR EL2 | min | rv32ui-sll | 0 | 1896 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-sll.log |
| VeeR EL2 | min | rv32ui-slli | 0 | 911 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-slli.log |
| VeeR EL2 | min | rv32ui-slt | 0 | 1618 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-slt.log |
| VeeR EL2 | min | rv32ui-slti | 0 | 830 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-slti.log |
| VeeR EL2 | min | rv32ui-sltiu | 0 | 830 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-sltiu.log |
| VeeR EL2 | min | rv32ui-sltu | 0 | 1618 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-sltu.log |
| VeeR EL2 | min | rv32ui-sra | 0 | 2077 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-sra.log |
| VeeR EL2 | min | rv32ui-srai | 0 | 998 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-srai.log |
| VeeR EL2 | min | rv32ui-srl | 0 | 2042 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-srl.log |
| VeeR EL2 | min | rv32ui-srli | 0 | 992 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-srli.log |
| VeeR EL2 | min | rv32ui-st_ld | 0 | 2217 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-st_ld.log |
| VeeR EL2 | min | rv32ui-sub | 0 | 1617 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-sub.log |
| VeeR EL2 | min | rv32ui-sw | 0 | 2173 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-sw.log |
| VeeR EL2 | min | rv32ui-xor | 0 | 2028 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-xor.log |
| VeeR EL2 | min | rv32ui-xori | 0 | 781 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32ui-xori.log |
| VeeR EL2 | min | rv32um-div | 0 | 314 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32um-div.log |
| VeeR EL2 | min | rv32um-divu | 0 | 314 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32um-divu.log |
| VeeR EL2 | min | rv32um-mul | 0 | 1732 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32um-mul.log |
| VeeR EL2 | min | rv32um-mulh | 0 | 1861 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32um-mulh.log |
| VeeR EL2 | min | rv32um-mulhsu | 0 | 1872 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32um-mulhsu.log |
| VeeR EL2 | min | rv32um-mulhu | 0 | 1872 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32um-mulhu.log |
| VeeR EL2 | min | rv32um-rem | 0 | 303 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32um-rem.log |
| VeeR EL2 | min | rv32um-remu | 0 | 303 | 0 | — | — | — | — | results/raw/sim/veer_el2_min/rv32um-remu.log |
| VeeR EL2 FPGA config | fpga | coremark | 0 | 12471790 | 12369671 | 10 | 0.808 | — | — | results/raw/sim/veer_el2_min_fpga/coremark.log |
| VeeR EL2 FPGA config | fpga | dhrystone | 0 | 912372 | 849645 | 500 | — | 1699.3 | 0.335 | results/raw/sim/veer_el2_min_fpga/dhrystone.log |
| VeeR EL2 FPGA config | fpga | hello | 0 | 6009 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/hello.log |
| VeeR EL2 FPGA config | fpga | rv32uc-rvc | 0 | 889 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32uc-rvc.log |
| VeeR EL2 FPGA config | fpga | rv32ui-add | 0 | 1647 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-add.log |
| VeeR EL2 FPGA config | fpga | rv32ui-addi | 0 | 870 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-addi.log |
| VeeR EL2 FPGA config | fpga | rv32ui-and | 0 | 2047 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-and.log |
| VeeR EL2 FPGA config | fpga | rv32ui-andi | 0 | 734 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-andi.log |
| VeeR EL2 FPGA config | fpga | rv32ui-auipc | 0 | 154 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-auipc.log |
| VeeR EL2 FPGA config | fpga | rv32ui-beq | 0 | 994 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-beq.log |
| VeeR EL2 FPGA config | fpga | rv32ui-bge | 0 | 1092 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-bge.log |
| VeeR EL2 FPGA config | fpga | rv32ui-bgeu | 0 | 1299 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-bgeu.log |
| VeeR EL2 FPGA config | fpga | rv32ui-blt | 0 | 994 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-blt.log |
| VeeR EL2 FPGA config | fpga | rv32ui-bltu | 0 | 1216 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-bltu.log |
| VeeR EL2 FPGA config | fpga | rv32ui-bne | 0 | 990 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-bne.log |
| VeeR EL2 FPGA config | fpga | rv32ui-jal | 0 | 133 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-jal.log |
| VeeR EL2 FPGA config | fpga | rv32ui-jalr | 0 | 428 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-jalr.log |
| VeeR EL2 FPGA config | fpga | rv32ui-lb | 0 | 977 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-lb.log |
| VeeR EL2 FPGA config | fpga | rv32ui-lbu | 0 | 993 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-lbu.log |
| VeeR EL2 FPGA config | fpga | rv32ui-ld_st | 0 | 4521 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-ld_st.log |
| VeeR EL2 FPGA config | fpga | rv32ui-lh | 0 | 1045 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-lh.log |
| VeeR EL2 FPGA config | fpga | rv32ui-lhu | 0 | 1078 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-lhu.log |
| VeeR EL2 FPGA config | fpga | rv32ui-lui | 0 | 187 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-lui.log |
| VeeR EL2 FPGA config | fpga | rv32ui-lw | 0 | 1125 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-lw.log |
| VeeR EL2 FPGA config | fpga | rv32ui-or | 0 | 2059 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-or.log |
| VeeR EL2 FPGA config | fpga | rv32ui-ori | 0 | 774 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-ori.log |
| VeeR EL2 FPGA config | fpga | rv32ui-sb | 0 | 1981 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-sb.log |
| VeeR EL2 FPGA config | fpga | rv32ui-sh | 0 | 2150 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-sh.log |
| VeeR EL2 FPGA config | fpga | rv32ui-simple | 0 | 72 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-simple.log |
| VeeR EL2 FPGA config | fpga | rv32ui-sll | 0 | 1896 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-sll.log |
| VeeR EL2 FPGA config | fpga | rv32ui-slli | 0 | 911 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-slli.log |
| VeeR EL2 FPGA config | fpga | rv32ui-slt | 0 | 1618 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-slt.log |
| VeeR EL2 FPGA config | fpga | rv32ui-slti | 0 | 830 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-slti.log |
| VeeR EL2 FPGA config | fpga | rv32ui-sltiu | 0 | 830 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-sltiu.log |
| VeeR EL2 FPGA config | fpga | rv32ui-sltu | 0 | 1618 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-sltu.log |
| VeeR EL2 FPGA config | fpga | rv32ui-sra | 0 | 2077 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-sra.log |
| VeeR EL2 FPGA config | fpga | rv32ui-srai | 0 | 998 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-srai.log |
| VeeR EL2 FPGA config | fpga | rv32ui-srl | 0 | 2042 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-srl.log |
| VeeR EL2 FPGA config | fpga | rv32ui-srli | 0 | 992 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-srli.log |
| VeeR EL2 FPGA config | fpga | rv32ui-st_ld | 0 | 2217 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-st_ld.log |
| VeeR EL2 FPGA config | fpga | rv32ui-sub | 0 | 1617 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-sub.log |
| VeeR EL2 FPGA config | fpga | rv32ui-sw | 0 | 2173 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-sw.log |
| VeeR EL2 FPGA config | fpga | rv32ui-xor | 0 | 2028 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-xor.log |
| VeeR EL2 FPGA config | fpga | rv32ui-xori | 0 | 781 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32ui-xori.log |
| VeeR EL2 FPGA config | fpga | rv32um-div | 0 | 314 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32um-div.log |
| VeeR EL2 FPGA config | fpga | rv32um-divu | 0 | 314 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32um-divu.log |
| VeeR EL2 FPGA config | fpga | rv32um-mul | 0 | 1732 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32um-mul.log |
| VeeR EL2 FPGA config | fpga | rv32um-mulh | 0 | 1861 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32um-mulh.log |
| VeeR EL2 FPGA config | fpga | rv32um-mulhsu | 0 | 1872 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32um-mulhsu.log |
| VeeR EL2 FPGA config | fpga | rv32um-mulhu | 0 | 1872 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32um-mulhu.log |
| VeeR EL2 FPGA config | fpga | rv32um-rem | 0 | 303 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32um-rem.log |
| VeeR EL2 FPGA config | fpga | rv32um-remu | 0 | 303 | 0 | — | — | — | — | results/raw/sim/veer_el2_min_fpga/rv32um-remu.log |
| VeeR EL2 | tcm | coremark | 0 | 3281780 | 3255415 | 10 | 3.072 | — | — | results/raw/sim/veer_el2_tcm/coremark.log |
| VeeR EL2 | tcm | dhrystone | 0 | 244395 | 227036 | 500 | — | 454.1 | 1.253 | results/raw/sim/veer_el2_tcm/dhrystone.log |
| VeeR EL2 | tcm | hello | 0 | 2038 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/hello.log |
| VeeR EL2 | tcm | rv32uc-rvc | 4101 | 75 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32uc-rvc.log |
| VeeR EL2 | tcm | rv32ui-add | 0 | 477 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-add.log |
| VeeR EL2 | tcm | rv32ui-addi | 0 | 245 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-addi.log |
| VeeR EL2 | tcm | rv32ui-and | 0 | 497 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-and.log |
| VeeR EL2 | tcm | rv32ui-andi | 0 | 202 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-andi.log |
| VeeR EL2 | tcm | rv32ui-auipc | 0 | 59 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-auipc.log |
| VeeR EL2 | tcm | rv32ui-beq | 0 | 314 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-beq.log |
| VeeR EL2 | tcm | rv32ui-bge | 0 | 342 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-bge.log |
| VeeR EL2 | tcm | rv32ui-bgeu | 0 | 367 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-bgeu.log |
| VeeR EL2 | tcm | rv32ui-blt | 0 | 314 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-blt.log |
| VeeR EL2 | tcm | rv32ui-bltu | 0 | 340 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-bltu.log |
| VeeR EL2 | tcm | rv32ui-bne | 0 | 316 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-bne.log |
| VeeR EL2 | tcm | rv32ui-jal | 0 | 54 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-jal.log |
| VeeR EL2 | tcm | rv32ui-jalr | 0 | 125 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-jalr.log |
| VeeR EL2 | tcm | rv32ui-lb | 0 | 257 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-lb.log |
| VeeR EL2 | tcm | rv32ui-lbu | 0 | 256 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-lbu.log |
| VeeR EL2 | tcm | rv32ui-ld_st | 0 | 960 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-ld_st.log |
| VeeR EL2 | tcm | rv32ui-lh | 0 | 273 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-lh.log |
| VeeR EL2 | tcm | rv32ui-lhu | 0 | 282 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-lhu.log |
| VeeR EL2 | tcm | rv32ui-lui | 0 | 62 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-lui.log |
| VeeR EL2 | tcm | rv32ui-lw | 0 | 286 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-lw.log |
| VeeR EL2 | tcm | rv32ui-or | 0 | 502 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-or.log |
| VeeR EL2 | tcm | rv32ui-ori | 0 | 208 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-ori.log |
| VeeR EL2 | tcm | rv32ui-sb | 0 | 473 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-sb.log |
| VeeR EL2 | tcm | rv32ui-sh | 0 | 525 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-sh.log |
| VeeR EL2 | tcm | rv32ui-simple | 0 | 38 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-simple.log |
| VeeR EL2 | tcm | rv32ui-sll | 0 | 505 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-sll.log |
| VeeR EL2 | tcm | rv32ui-slli | 0 | 244 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-slli.log |
| VeeR EL2 | tcm | rv32ui-slt | 0 | 471 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-slt.log |
| VeeR EL2 | tcm | rv32ui-slti | 0 | 240 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-slti.log |
| VeeR EL2 | tcm | rv32ui-sltiu | 0 | 240 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-sltiu.log |
| VeeR EL2 | tcm | rv32ui-sltu | 0 | 471 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-sltu.log |
| VeeR EL2 | tcm | rv32ui-sra | 0 | 524 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-sra.log |
| VeeR EL2 | tcm | rv32ui-srai | 0 | 260 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-srai.log |
| VeeR EL2 | tcm | rv32ui-srl | 0 | 518 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-srl.log |
| VeeR EL2 | tcm | rv32ui-srli | 0 | 253 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-srli.log |
| VeeR EL2 | tcm | rv32ui-st_ld | 0 | 480 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-st_ld.log |
| VeeR EL2 | tcm | rv32ui-sub | 0 | 469 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-sub.log |
| VeeR EL2 | tcm | rv32ui-sw | 0 | 532 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-sw.log |
| VeeR EL2 | tcm | rv32ui-xor | 0 | 499 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-xor.log |
| VeeR EL2 | tcm | rv32ui-xori | 0 | 210 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32ui-xori.log |
| VeeR EL2 | tcm | rv32um-div | 0 | 127 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32um-div.log |
| VeeR EL2 | tcm | rv32um-divu | 0 | 126 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32um-divu.log |
| VeeR EL2 | tcm | rv32um-mul | 0 | 471 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32um-mul.log |
| VeeR EL2 | tcm | rv32um-mulh | 0 | 472 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32um-mulh.log |
| VeeR EL2 | tcm | rv32um-mulhsu | 0 | 471 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32um-mulhsu.log |
| VeeR EL2 | tcm | rv32um-mulhu | 0 | 471 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32um-mulhu.log |
| VeeR EL2 | tcm | rv32um-rem | 0 | 127 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32um-rem.log |
| VeeR EL2 | tcm | rv32um-remu | 0 | 126 | 0 | — | — | — | — | results/raw/sim/veer_el2_tcm/rv32um-remu.log |

## SKY130 synthesis

The fmax column is a pre-layout estimate at the typical corner. It is not routed sign-off timing.

| Core | Config | Top | Target MHz | Frontend | Cells | Area µm² | Sequential area µm² | Flops | Latches | Pre-layout fmax MHz | Raw reports |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Hazard3 | default | vendor top (sensitivity) | 50 | Yosys read_verilog | 12823 | 152032.1 | 42817.3 | 1849 | 0 | 49.0 | results/raw/sky130/hazard3/synth_default_50MHz |
| Hazard3 | default | core + wrapper | 50 | Yosys read_verilog | 13152 | 156518.9 | 45208.4 | 1940 | 0 | 47.6 | results/raw/sky130/hazard3/synth_default_wrap_50MHz |
| Ibex | small | vendor top (sensitivity) | 50 | yosys-slang | 12173 | 152431.2 | 49870.3 | 1950 | 1 | 48.2 | results/raw/sky130/ibex/synth_default_50MHz |
| Ibex | small | core + wrapper | 50 | yosys-slang | 11922 | 150476.8 | 49187.2 | 1924 | 1 | 49.3 | results/raw/sky130/ibex/synth_default_wrap_50MHz |
| VeeR EL2 | bp | vendor top (sensitivity) | 50 | yosys-slang | 61383 | 720778.8 | 223891.0 | 8521 | 305 | 20.1 | results/raw/sky130/veer_el2/synth_bp_50MHz |
| VeeR EL2 | min | vendor top (sensitivity) | 50 | yosys-slang | 56639 | 650156.1 | 185791.9 | 7071 | 258 | 25.1 | results/raw/sky130/veer_el2/synth_min_50MHz |
| VeeR EL2 | min | core + wrapper | 50 | yosys-slang | 50627 | 579031.6 | 165078.3 | 6384 | 224 | 24.2 | results/raw/sky130/veer_el2/synth_min_wrap_50MHz |

## SKY130 layout and sign-off checks

A `no` sign-off result means at least one required corner/check still has a violation. DRC/LVS/antenna clean alone does not establish timing sign-off.

| Core | Config | Target MHz | Run | fmax tt MHz | fmax ss MHz | fmax ss maxRC MHz | Magic DRC | KLayout DRC | LVS errors | Antenna nets | Setup WS tt ns | Setup WS ss ns | Setup WS ff ns | Setup violations | Worst hold WS ns | Hold violations | Slew violations | Cap violations | Die area µm² | Core area µm² | Std cells | Default power W | CoreMark power W | Annotated regs | Sign-off clean | Raw run |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Hazard3 | default | 30 | harden_default_wrap_30MHz | 52.0 | 25.9 | 25.3 | 0 | 0 | 0 | 0 | 11.915 | -5.21 | 17.195 | 307 | 0.064 | 0 | 3190 | 5 | 331626 | 311899 | 22566 | 0.02070716954767704 | — | — | no | results/raw/sky130/hazard3/harden_default_wrap_30MHz |
| Hazard3 | default | 30 | harden_default_wrap_30MHz_postroute | 61.0 | 30.5 | 29.9 | 0 | 0 | 0 | 0 | 13.311 | 0.576 | 17.211 | 4 | 0.062 | 0 | 595 | 2 | 331626 | 311899 | 22723 | 0.02075297385454178 | 0.0102 | 1940/1940 | no | results/raw/sky130/hazard3/harden_default_wrap_30MHz_postroute |
| Hazard3 | default | 40 | harden_default_wrap_40MHz_baseline | 65.9 | 34.3 | 33.1 | 0 | 0 | 0 | 0 | 8.253 | -4.132 | 11.704 | 1375 | 0.107 | 0 | 5707 | 36 | 331626 | 311899 | 21879 | 0.027770768851041794 | — | — | no | results/raw/sky130/hazard3/harden_default_wrap_40MHz_baseline |
| Hazard3 | default | 40 | harden_default_wrap_40MHz_margin | 67.0 | 34.5 | 33.5 | 0 | 0 | 0 | 0 | 8.527 | -3.985 | 12.34 | 716 | 0.088 | 0 | 2795 | 3 | 331626 | 311899 | 22619 | 0.027857452630996704 | — | — | no | results/raw/sky130/hazard3/harden_default_wrap_40MHz_margin |
| Hazard3 | default | 40 | harden_default_wrap_40MHz_multicorner | 67.0 | 34.5 | 33.5 | 0 | 0 | 0 | 0 | 8.527 | -3.985 | 12.34 | 716 | 0.088 | 0 | 2795 | 3 | 331626 | 311899 | 22619 | 0.027857452630996704 | — | — | no | results/raw/sky130/hazard3/harden_default_wrap_40MHz_multicorner |
| Hazard3 | default | 40 | harden_default_wrap_40MHz_nodlybuf | 66.7 | 34.2 | 33.2 | 0 | 0 | 0 | 0 | 8.499 | -4.224 | 12.121 | 758 | 0.101 | 0 | 5903 | 68 | 331626 | 311899 | 22222 | 0.027000296860933304 | — | — | no | results/raw/sky130/hazard3/harden_default_wrap_40MHz_nodlybuf |
| Hazard3 | default | 40 | harden_default_wrap_40MHz_pgrt | 66.6 | 34.2 | 33.1 | 0 | 0 | 0 | 0 | 8.468 | -4.252 | 12.299 | 750 | 0.102 | 0 | 5647 | 50 | 331626 | 311899 | 22219 | 0.027001414448022842 | — | — | no | results/raw/sky130/hazard3/harden_default_wrap_40MHz_pgrt |
| Ibex | small | 30 | harden_default_wrap_30MHz_postroute | 52.7 | 29.6 | 28.9 | 0 | 0 | 0 | 0 | 9.74 | -0.397 | 9.86 | 274 | 0.063 | 0 | 881 | 4 | 319185 | 299778 | 21970 | 0.05092117562890053 | 0.0221 | 1924/1924 | no | results/raw/sky130/ibex/harden_default_wrap_30MHz_postroute |
| Ibex | small | 40 | harden_default_wrap_40MHz | 63.6 | 33.3 | 32.4 | 0 | 0 | 0 | 0 | 7.234 | -5.063 | 7.356 | 3667 | 0.105 | 0 | 3652 | 1 | 319185 | 299778 | 21800 | 0.06809662282466888 | — | — | no | results/raw/sky130/ibex/harden_default_wrap_40MHz |

## FPGA Vivado implementation

These are Vivado synthesis/implementation reports for the Zynq-7020 PL design. Power is Vivado's vectorless estimate; cycle-accurate behavior is independently covered by the FPGA simulation checks.

| Core | Config | Clock MHz | WNS ns | WHS ns | Estimated fmax MHz | Setup failing endpoints | Hold failing endpoints | Core LUTs | Core FFs | Core LUTRAM | Core BRAM36 | Core BRAM18 | Core DSP | Total LUTs | Total FFs | Total BRAM36 | Total power W | Dynamic power W | FPGA sim vs RTL | Reports |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Hazard3 | default | 25.000000 | 20.187 | 0.043 | 50.5 | 0 | 0 | 2403 | 774 | 0 | 0 | 2 | 3 | 3372 | 1883 | 81 | 1.755 | 1.608 | 52/52 | results/raw/fpga/hazard3/vivado_default_25MHz |
| Hazard3 | default | 50.000000 | 3.228 | 0.067 | 59.6 | 0 | 0 | 2403 | 774 | 0 | 0 | 2 | 3 | 3370 | 1883 | 81 | 1.843 | 1.694 | 52/52 | results/raw/fpga/hazard3/vivado_default_50MHz |
| Ibex | default | 25.000000 | 17.002 | 0.042 | 43.5 | 0 | 0 | 3047 | 1912 | 0 | 0 | 0 | 1 | 3967 | 3017 | 80 | 1.749 | 1.603 | 52/52 | results/raw/fpga/ibex/vivado_default_25MHz |
| Ibex | default | 50.000000 | 1.621 | 0.044 | 54.4 | 0 | 0 | 3063 | 1912 | 0 | 0 | 0 | 1 | 3989 | 3017 | 80 | 1.831 | 1.682 | 52/52 | results/raw/fpga/ibex/vivado_default_50MHz |
| VeeR EL2 | min_fpga | 25.000000 | 0.278 | 0.050 | 25.2 | 0 | 0 | 17390 | 6223 | 0 | 0 | 0 | 4 | 18390 | 7331 | 80 | 1.753 | 1.606 | 52/52 | results/raw/fpga/veer_el2/vivado_min_fpga_25MHz |
| VeeR EL2 | min_fpga | 30.000000 | -0.369 | 0.024 | 29.7 | 2 | 0 | 17529 | 6223 | 0 | 0 | 0 | 4 | 18533 | 7331 | 80 | 1.764 | 1.617 | 52/52 | results/raw/fpga/veer_el2/vivado_min_fpga_30MHz |
| VeeR EL2 | min_fpga | 50.000000 | -11.690 | 0.042 | 31.6 | 1581 | 0 | 17928 | 6257 | 0 | 0 | 0 | 4 | 18929 | 7365 | 80 | 1.838 | 1.689 | 52/52 | results/raw/fpga/veer_el2/vivado_min_fpga_50MHz |

## Interpretation notes

- The RTL simulation table includes the VeeR `tcm` sensitivity configuration, which passes 51/52; the main VeeR `min` configuration passes 52/52.
- The FPGA simulation check compares the 52-program FPGA-shell simulation against RTL reference results; it is not a physical-board measurement.
- Vivado timing is shown for every collected clock point. Negative WNS indicates setup timing failure; negative WHS would indicate hold failure.
- Layout `signoff_clean` evaluates setup, hold, slew, cap, DRC, LVS, and antenna checks across required corners.
- Raw report/log paths are listed in each table for traceability.
