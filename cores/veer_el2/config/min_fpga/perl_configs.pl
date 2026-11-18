#  Copyright 2019-2026 Western Digital Corporation or its affiliates.
#  Copyright 2022-2026 Antmicro <www.antmicro.com>
# 
#  SPDX-License-Identifier: Apache-2.0
#  Licensed under the Apache License, Version 2.0, see LICENSE for details.
# 
#  This is an automatically generated file by dwitisuchak on Wed Nov 18 18:00:41 IST 2026
# 
#  cmd:    veer -target=typical_pd -set=icache_enable=0 -set=user_mode=0 -set=lockstep_enable=0 -set=bitmanip_zba=0 -set=bitmanip_zbb=0 -set=bitmanip_zbc=0 -set=bitmanip_zbe=0 -set=bitmanip_zbf=0 -set=bitmanip_zbp=0 -set=bitmanip_zbr=0 -set=bitmanip_zbs=0 -set=pic_total_int=1 -set=fpga_optimize=1 -set=btb_enable=0 -set=iccm_enable=0 -set=dccm_enable=0 
# 
# To use this in a perf script, use 'require $RV_ROOT/configs/config.pl'
# Reference the hash via $config{name}..


%config = (
            'iccm' => {
                        'iccm_offset' => '0xe000000',
                        'iccm_ecc_width' => '7',
                        'iccm_size' => 64,
                        'iccm_data_cell' => 'ram_4096x39',
                        'iccm_bank_bits' => 2,
                        'iccm_eadr' => '0xee00ffff',
                        'iccm_rows' => '4096',
                        'iccm_num_banks_4' => '',
                        'iccm_bits' => 16,
                        'iccm_size_64' => '',
                        'iccm_sadr' => '0xee000000',
                        'iccm_num_banks' => '4',
                        'iccm_reserved' => '0x1000',
                        'iccm_bank_index_lo' => 4,
                        'iccm_index_bits' => 12,
                        'iccm_region' => '0xe',
                        'iccm_bank_hi' => 3
                      },
            'core' => {
                        'bitmanip_zbr' => 0,
                        'bitmanip_zbe' => 0,
                        'bitmanip_zbp' => 0,
                        'lsu_stbuf_depth' => '4',
                        'div_new' => 1,
                        'fpga_optimize' => 1,
                        'bitmanip_zbs' => '0',
                        'lsu_num_nbload_width' => '2',
                        'no_iccm_no_icache' => 1,
                        'bitmanip_zbb' => '0',
                        'iccm_icache' => 'derived',
                        'bitmanip_zba' => '0',
                        'icache_only' => 'derived',
                        'bitmanip_zbc' => '0',
                        'lsu_num_nbload' => '4',
                        'dma_buf_depth' => '5',
                        'timer_legal_en' => '1',
                        'lsu2dma' => 0,
                        'iccm_only' => 'derived',
                        'bitmanip_zbf' => 0,
                        'fast_interrupt_redirect' => 0,
                        'div_bit' => '4'
                      },
            'regwidth' => '32',
            'physical' => '1',
            'user_ec_rv_icg' => 'user_clock_gate',
            'reset_vec' => '0x80000000',
            'dccm' => {
                        'dccm_eadr' => '0xf0043fff',
                        'dccm_bank_bits' => 1,
                        'dccm_data_cell' => 'ram_2048x39',
                        'dccm_size' => 16,
                        'dccm_rows' => '2048',
                        'dccm_fdata_width' => 39,
                        'dccm_bits' => 14,
                        'dccm_width_bits' => 2,
                        'lsu_sb_bits' => 14,
                        'dccm_num_banks_2' => '',
                        'dccm_ecc_width' => 7,
                        'dccm_offset' => '0x40000',
                        'dccm_data_width' => 32,
                        'dccm_size_16' => '',
                        'dccm_reserved' => '0x1400',
                        'dccm_num_banks' => '2',
                        'dccm_sadr' => '0xf0040000',
                        'dccm_region' => '0xf',
                        'dccm_index_bits' => 11,
                        'dccm_byte_width' => '4'
                      },
            'pic' => {
                       'pic_meipt_offset' => '0x3004',
                       'pic_meie_mask' => '0x1',
                       'pic_meigwctrl_offset' => '0x4000',
                       'pic_meipl_mask' => '0xf',
                       'pic_total_int' => 1,
                       'pic_base_addr' => '0xf00c0000',
                       'pic_meip_mask' => '0x0',
                       'pic_offset' => '0xc0000',
                       'pic_mpiccfg_mask' => '0x1',
                       'pic_meipl_count' => 1,
                       'pic_mpiccfg_count' => 1,
                       'pic_bits' => 15,
                       'pic_meie_offset' => '0x2000',
                       'pic_meigwclr_offset' => '0x5000',
                       'pic_meip_count' => 0,
                       'pic_meipt_count' => 1,
                       'pic_total_int_plus1' => 2,
                       'pic_mpiccfg_offset' => '0x3000',
                       'pic_meip_offset' => '0x1000',
                       'pic_size' => 32,
                       'pic_meipl_offset' => '0x0000',
                       'pic_int_words' => 0,
                       'pic_meigwclr_mask' => '0x0',
                       'pic_region' => '0xf',
                       'pic_meigwctrl_count' => 1,
                       'pic_meipt_mask' => '0x0',
                       'pic_meie_count' => 1,
                       'pic_meigwclr_count' => 1,
                       'pic_meigwctrl_mask' => '0x3'
                     },
            'protection' => {
                              'inst_access_enable6' => '0x0',
                              'data_access_enable6' => '0x0',
                              'data_access_mask3' => '0xffffffff',
                              'inst_access_mask1' => '0xffffffff',
                              'data_access_enable0' => '0x0',
                              'inst_access_mask4' => '0xffffffff',
                              'inst_access_addr6' => '0x00000000',
                              'data_access_mask1' => '0xffffffff',
                              'inst_access_enable0' => '0x0',
                              'data_access_addr6' => '0x00000000',
                              'data_access_mask4' => '0xffffffff',
                              'inst_access_mask3' => '0xffffffff',
                              'data_access_enable3' => '0x0',
                              'inst_access_enable2' => '0x0',
                              'data_access_mask5' => '0xffffffff',
                              'inst_access_enable3' => '0x0',
                              'inst_access_mask5' => '0xffffffff',
                              'data_access_enable2' => '0x0',
                              'data_access_mask0' => '0xffffffff',
                              'inst_access_addr7' => '0x00000000',
                              'data_access_mask2' => '0xffffffff',
                              'inst_access_mask2' => '0xffffffff',
                              'data_access_addr7' => '0x00000000',
                              'inst_access_mask0' => '0xffffffff',
                              'inst_access_addr5' => '0x00000000',
                              'data_access_addr5' => '0x00000000',
                              'inst_access_addr0' => '0x00000000',
                              'data_access_mask7' => '0xffffffff',
                              'data_access_enable1' => '0x0',
                              'data_access_enable5' => '0x0',
                              'pmp_entries' => '16',
                              'inst_access_addr2' => '0x00000000',
                              'data_access_addr2' => '0x00000000',
                              'inst_access_mask7' => '0xffffffff',
                              'data_access_addr0' => '0x00000000',
                              'inst_access_enable5' => '0x0',
                              'inst_access_enable1' => '0x0',
                              'inst_access_addr3' => '0x00000000',
                              'data_access_enable4' => '0x0',
                              'inst_access_enable7' => '0x0',
                              'data_access_addr1' => '0x00000000',
                              'data_access_mask6' => '0xffffffff',
                              'data_access_addr4' => '0x00000000',
                              'inst_access_addr1' => '0x00000000',
                              'data_access_enable7' => '0x0',
                              'inst_access_addr4' => '0x00000000',
                              'inst_access_mask6' => '0xffffffff',
                              'data_access_addr3' => '0x00000000',
                              'inst_access_enable4' => '0x0'
                            },
            'num_mmode_perf_regs' => '4',
            'numiregs' => '32',
            'nmi_vec' => '0x11110000',
            'retstack' => {
                            'ret_stack_size' => '2'
                          },
            'bht' => {
                       'bht_addr_hi' => 7,
                       'bht_size' => 128,
                       'bht_ghr_size' => 6,
                       'bht_hash_string' => '{ghr[5:4], hashin[5:2]^ghr[4-1:0]} // cf1',
                       'bht_array_depth' => 64,
                       'bht_ghr_range' => '5:0',
                       'bht_addr_lo' => '2',
                       'bht_ghr_hash_1' => 1
                     },
            'btb' => {
                       'btb_btag_fold' => 1,
                       'btb_fold2_index_hash' => 0,
                       'btb_addr_lo' => '2',
                       'btb_index2_hi' => 9,
                       'btb_size' => 32,
                       'btb_index3_hi' => 13,
                       'btb_index1_hi' => 5,
                       'btb_array_depth' => 16,
                       'btb_index3_lo' => 10,
                       'btb_index2_lo' => 6,
                       'btb_index1_lo' => '2',
                       'btb_btag_size' => 9,
                       'btb_toffset_size' => '12',
                       'btb_addr_hi' => 5
                     },
            'bus' => {
                       'ifu_bus_tag' => '3',
                       'ifu_bus_id' => '1',
                       'lsu_bus_tag' => 3,
                       'lsu_bus_id' => '1',
                       'bus_prty_default' => '3',
                       'ifu_bus_prty' => '2',
                       'lsu_bus_prty' => '2',
                       'dma_bus_prty' => '2',
                       'sb_bus_prty' => '2',
                       'dma_bus_tag' => '1',
                       'sb_bus_tag' => '1',
                       'dma_bus_id' => '1',
                       'sb_bus_id' => '1'
                     },
            'memmap' => {
                          'unused_region2' => '0x60000000',
                          'external_data_1' => '0xb0000000',
                          'unused_region7' => '0x10000000',
                          'serialio' => '0xd0580000',
                          'unused_region5' => '0x30000000',
                          'unused_region0' => '0x90000000',
                          'debug_sb_mem' => '0xa0580000',
                          'unused_region8' => '0x00000000',
                          'unused_region1' => '0x70000000',
                          'consoleio' => '0xd0580000',
                          'unused_region6' => '0x20000000',
                          'unused_region4' => '0x40000000',
                          'external_data' => '0xc0580000',
                          'unused_region3' => '0x50000000'
                        },
            'perf_events' => [
                               1,
                               2,
                               3,
                               4,
                               5,
                               6,
                               7,
                               8,
                               9,
                               10,
                               11,
                               12,
                               13,
                               14,
                               15,
                               16,
                               17,
                               18,
                               19,
                               20,
                               21,
                               22,
                               23,
                               24,
                               25,
                               26,
                               27,
                               28,
                               30,
                               31,
                               32,
                               34,
                               35,
                               36,
                               37,
                               38,
                               39,
                               40,
                               41,
                               42,
                               43,
                               44,
                               45,
                               46,
                               47,
                               48,
                               49,
                               50,
                               54,
                               55,
                               56,
                               512,
                               513,
                               514,
                               515,
                               516
                             ],
            'xlen' => 32,
            'max_mmode_perf_event' => '516',
            'testbench' => {
                             'CPU_TOP' => '`RV_TOP.veer',
                             'build_axi_native' => 1,
                             'ext_addrwidth' => '32',
                             'lderr_rollback' => '1',
                             'build_axi4' => 1,
                             'ext_datawidth' => '64',
                             'sterr_rollback' => '0',
                             'RV_TOP' => '`TOP.rvtop_wrapper.rvtop',
                             'clock_period' => '100',
                             'SDVT_AHB' => 0,
                             'TOP' => 'tb_top'
                           },
            'harts' => 1,
            'config_key' => '32\'hdeadbeef',
            'target' => 'typical_pd',
            'icache' => {
                          'icache_scnd_last' => 6,
                          'icache_tag_lo' => 13,
                          'icache_num_lines_way' => '128',
                          'icache_tag_num_bypass' => '2',
                          'icache_num_bypass_width' => 2,
                          'icache_index_hi' => 12,
                          'icache_banks_way' => 2,
                          'icache_bank_lo' => 3,
                          'icache_bank_bits' => 1,
                          'icache_fdata_width' => 71,
                          'icache_bank_width' => 8,
                          'icache_waypack' => '1',
                          'icache_2banks' => '1',
                          'icache_ln_sz' => 64,
                          'icache_tag_index_lo' => '6',
                          'icache_status_bits' => 1,
                          'icache_tag_cell' => 'ram_128x25',
                          'icache_beat_bits' => 3,
                          'icache_data_cell' => 'ram_512x71',
                          'icache_bank_hi' => 3,
                          'icache_tag_depth' => 128,
                          'icache_size' => 16,
                          'icache_num_lines_bank' => '64',
                          'icache_num_beats' => 8,
                          'icache_num_lines' => 256,
                          'icache_tag_bypass_enable' => '1',
                          'icache_num_bypass' => '2',
                          'icache_bypass_enable' => '1',
                          'icache_tag_num_bypass_width' => 2,
                          'icache_data_index_lo' => 4,
                          'icache_ecc' => '1',
                          'icache_beat_addr_hi' => 5,
                          'icache_data_width' => 64,
                          'icache_num_ways' => 2,
                          'icache_data_depth' => '512'
                        },
            'tec_rv_icg' => 'clockhdr',
            'triggers' => [
                            {
                              'mask' => [
                                          '0x081818c7',
                                          '0xffffffff',
                                          '0x00000000'
                                        ],
                              'reset' => [
                                           '0x23e00000',
                                           '0x00000000',
                                           '0x00000000'
                                         ],
                              'poke_mask' => [
                                               '0x081818c7',
                                               '0xffffffff',
                                               '0x00000000'
                                             ]
                            },
                            {
                              'poke_mask' => [
                                               '0x081810c7',
                                               '0xffffffff',
                                               '0x00000000'
                                             ],
                              'reset' => [
                                           '0x23e00000',
                                           '0x00000000',
                                           '0x00000000'
                                         ],
                              'mask' => [
                                          '0x081810c7',
                                          '0xffffffff',
                                          '0x00000000'
                                        ]
                            },
                            {
                              'poke_mask' => [
                                               '0x081818c7',
                                               '0xffffffff',
                                               '0x00000000'
                                             ],
                              'mask' => [
                                          '0x081818c7',
                                          '0xffffffff',
                                          '0x00000000'
                                        ],
                              'reset' => [
                                           '0x23e00000',
                                           '0x00000000',
                                           '0x00000000'
                                         ]
                            },
                            {
                              'poke_mask' => [
                                               '0x081810c7',
                                               '0xffffffff',
                                               '0x00000000'
                                             ],
                              'mask' => [
                                          '0x081810c7',
                                          '0xffffffff',
                                          '0x00000000'
                                        ],
                              'reset' => [
                                           '0x23e00000',
                                           '0x00000000',
                                           '0x00000000'
                                         ]
                            }
                          ],
            'even_odd_trigger_chains' => 'true',
            'csr' => {
                       'mcounteren' => {
                                         'exists' => 'false'
                                       },
                       'mhartid' => {
                                      'poke_mask' => '0xfffffff0',
                                      'mask' => '0x0',
                                      'exists' => 'true',
                                      'reset' => '0x0'
                                    },
                       'mhpmcounter4h' => {
                                            'reset' => '0x0',
                                            'mask' => '0xffffffff',
                                            'exists' => 'true'
                                          },
                       'mhpmcounter5' => {
                                           'reset' => '0x0',
                                           'mask' => '0xffffffff',
                                           'exists' => 'true'
                                         },
                       'meipt' => {
                                    'reset' => '0x0',
                                    'mask' => '0xf',
                                    'exists' => 'true',
                                    'comment' => 'External interrupt priority threshold.',
                                    'number' => '0xbc9'
                                  },
                       'mhpmcounter6h' => {
                                            'reset' => '0x0',
                                            'exists' => 'true',
                                            'mask' => '0xffffffff'
                                          },
                       'misa' => {
                                   'mask' => '0x0',
                                   'exists' => 'true',
                                   'reset' => '0x40001104'
                                 },
                       'mhpmevent5' => {
                                         'exists' => 'true',
                                         'mask' => '0xffffffff',
                                         'reset' => '0x0'
                                       },
                       'mie' => {
                                  'mask' => '0x70000888',
                                  'exists' => 'true',
                                  'reset' => '0x0'
                                },
                       'mfdhs' => {
                                    'number' => '0x7cf',
                                    'comment' => 'Force Debug Halt Status',
                                    'exists' => 'true',
                                    'mask' => '0x00000003',
                                    'reset' => '0x0'
                                  },
                       'mitctl0' => {
                                      'reset' => '0x1',
                                      'mask' => '0x00000007',
                                      'exists' => 'true',
                                      'number' => '0x7d4'
                                    },
                       'mhpmevent6' => {
                                         'reset' => '0x0',
                                         'mask' => '0xffffffff',
                                         'exists' => 'true'
                                       },
                       'mhpmcounter3' => {
                                           'reset' => '0x0',
                                           'mask' => '0xffffffff',
                                           'exists' => 'true'
                                         },
                       'mvendorid' => {
                                        'mask' => '0x0',
                                        'exists' => 'true',
                                        'reset' => '0x45'
                                      },
                       'mitbnd1' => {
                                      'reset' => '0xffffffff',
                                      'mask' => '0xffffffff',
                                      'exists' => 'true',
                                      'number' => '0x7d6'
                                    },
                       'dicad1' => {
                                     'mask' => '0x3',
                                     'exists' => 'true',
                                     'reset' => '0x0',
                                     'debug' => 'true',
                                     'number' => '0x7ca',
                                     'comment' => 'Cache diagnostics.'
                                   },
                       'dicawics' => {
                                       'number' => '0x7c8',
                                       'comment' => 'Cache diagnostics.',
                                       'mask' => '0x0130fffc',
                                       'exists' => 'true',
                                       'reset' => '0x0',
                                       'debug' => 'true'
                                     },
                       'meicurpl' => {
                                       'reset' => '0x0',
                                       'exists' => 'true',
                                       'mask' => '0xf',
                                       'comment' => 'External interrupt current priority level.',
                                       'number' => '0xbcc'
                                     },
                       'mitcnt1' => {
                                      'reset' => '0x0',
                                      'exists' => 'true',
                                      'mask' => '0xffffffff',
                                      'number' => '0x7d5'
                                    },
                       'time' => {
                                   'exists' => 'false'
                                 },
                       'mcgc' => {
                                   'reset' => '0x200',
                                   'mask' => '0x000003ff',
                                   'exists' => 'true',
                                   'poke_mask' => '0x000003ff',
                                   'number' => '0x7f8'
                                 },
                       'mhpmevent3' => {
                                         'reset' => '0x0',
                                         'exists' => 'true',
                                         'mask' => '0xffffffff'
                                       },
                       'mrac' => {
                                   'mask' => '0xffffffff',
                                   'exists' => 'true',
                                   'reset' => '0x0',
                                   'number' => '0x7c0',
                                   'shared' => 'true',
                                   'comment' => 'Memory region io and cache control.'
                                 },
                       'dicago' => {
                                     'reset' => '0x0',
                                     'debug' => 'true',
                                     'mask' => '0x0',
                                     'exists' => 'true',
                                     'comment' => 'Cache diagnostics.',
                                     'number' => '0x7cb'
                                   },
                       'mstatus' => {
                                      'reset' => '0x1800',
                                      'exists' => 'true',
                                      'mask' => '0x88'
                                    },
                       'dmst' => {
                                   'mask' => '0x0',
                                   'exists' => 'true',
                                   'reset' => '0x0',
                                   'debug' => 'true',
                                   'number' => '0x7c4',
                                   'comment' => 'Memory synch trigger: Flush caches in debug mode.'
                                 },
                       'mfdc' => {
                                   'number' => '0x7f9',
                                   'mask' => '0x00071fff',
                                   'exists' => 'true',
                                   'reset' => '0x00070040'
                                 },
                       'meicpct' => {
                                      'reset' => '0x0',
                                      'mask' => '0x0',
                                      'exists' => 'true',
                                      'comment' => 'External claim id/priority capture.',
                                      'number' => '0xbca'
                                    },
                       'mdccmect' => {
                                       'number' => '0x7f2',
                                       'reset' => '0x0',
                                       'mask' => '0xffffffff',
                                       'exists' => 'true'
                                     },
                       'mscause' => {
                                      'number' => '0x7ff',
                                      'reset' => '0x0',
                                      'mask' => '0x0000000f',
                                      'exists' => 'true'
                                    },
                       'miccmect' => {
                                       'number' => '0x7f1',
                                       'mask' => '0xffffffff',
                                       'exists' => 'true',
                                       'reset' => '0x0'
                                     },
                       'tselect' => {
                                      'reset' => '0x0',
                                      'exists' => 'true',
                                      'mask' => '0x3'
                                    },
                       'mitctl1' => {
                                      'reset' => '0x1',
                                      'mask' => '0x0000000f',
                                      'exists' => 'true',
                                      'number' => '0x7d7'
                                    },
                       'mfdht' => {
                                    'reset' => '0x0',
                                    'shared' => 'true',
                                    'comment' => 'Force Debug Halt Threshold',
                                    'number' => '0x7ce',
                                    'mask' => '0x0000003f',
                                    'exists' => 'true'
                                  },
                       'mcpc' => {
                                   'reset' => '0x0',
                                   'mask' => '0x0',
                                   'exists' => 'true',
                                   'comment' => 'Core pause',
                                   'number' => '0x7c2'
                                 },
                       'micect' => {
                                     'reset' => '0x0',
                                     'mask' => '0xffffffff',
                                     'exists' => 'true',
                                     'number' => '0x7f0'
                                   },
                       'instret' => {
                                      'exists' => 'false'
                                    },
                       'mcountinhibit' => {
                                            'poke_mask' => '0x7d',
                                            'reset' => '0x0',
                                            'exists' => 'true',
                                            'mask' => '0x7d',
                                            'commnet' => 'Performance counter inhibit. One bit per counter.'
                                          },
                       'meicidpl' => {
                                       'mask' => '0xf',
                                       'exists' => 'true',
                                       'reset' => '0x0',
                                       'number' => '0xbcb',
                                       'comment' => 'External interrupt claim id priority level.'
                                     },
                       'mip' => {
                                  'reset' => '0x0',
                                  'mask' => '0x0',
                                  'exists' => 'true',
                                  'poke_mask' => '0x70000888'
                                },
                       'mimpid' => {
                                     'reset' => '0x4',
                                     'exists' => 'true',
                                     'mask' => '0x0'
                                   },
                       'mhpmcounter3h' => {
                                            'mask' => '0xffffffff',
                                            'exists' => 'true',
                                            'reset' => '0x0'
                                          },
                       'dcsr' => {
                                   'debug' => 'true',
                                   'reset' => '0x40000003',
                                   'exists' => 'true',
                                   'mask' => '0x00008c04',
                                   'poke_mask' => '0x00008dcc'
                                 },
                       'marchid' => {
                                      'reset' => '0x00000010',
                                      'exists' => 'true',
                                      'mask' => '0x0'
                                    },
                       'cycle' => {
                                    'exists' => 'false'
                                  },
                       'mhpmcounter5h' => {
                                            'reset' => '0x0',
                                            'mask' => '0xffffffff',
                                            'exists' => 'true'
                                          },
                       'mhpmcounter4' => {
                                           'reset' => '0x0',
                                           'exists' => 'true',
                                           'mask' => '0xffffffff'
                                         },
                       'dicad0' => {
                                     'number' => '0x7c9',
                                     'comment' => 'Cache diagnostics.',
                                     'mask' => '0xffffffff',
                                     'exists' => 'true',
                                     'reset' => '0x0',
                                     'debug' => 'true'
                                   },
                       'mpmc' => {
                                   'number' => '0x7c6',
                                   'reset' => '0x2',
                                   'exists' => 'true',
                                   'mask' => '0x2'
                                 },
                       'mitbnd0' => {
                                      'exists' => 'true',
                                      'mask' => '0xffffffff',
                                      'reset' => '0xffffffff',
                                      'number' => '0x7d3'
                                    },
                       'mitcnt0' => {
                                      'exists' => 'true',
                                      'mask' => '0xffffffff',
                                      'reset' => '0x0',
                                      'number' => '0x7d2'
                                    },
                       'mhpmevent4' => {
                                         'reset' => '0x0',
                                         'exists' => 'true',
                                         'mask' => '0xffffffff'
                                       },
                       'mhpmcounter6' => {
                                           'reset' => '0x0',
                                           'exists' => 'true',
                                           'mask' => '0xffffffff'
                                         }
                     }
          );
1;
