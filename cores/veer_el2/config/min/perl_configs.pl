#  Copyright 2019-2026 Western Digital Corporation or its affiliates.
#  Copyright 2022-2026 Antmicro <www.antmicro.com>
# 
#  SPDX-License-Identifier: Apache-2.0
#  Licensed under the Apache License, Version 2.0, see LICENSE for details.
# 
#  This is an automatically generated file by dwitisuchak on Mon Nov  9 19:43:36 IST 2026
# 
#  cmd:    veer -target=typical_pd -fpga_optimize=0 -set=iccm_enable=0 -set=dccm_enable=0 -set=icache_enable=0 -set=user_mode=0 -set=lockstep_enable=0 -set=bitmanip_zba=0 -set=bitmanip_zbb=0 -set=bitmanip_zbc=0 -set=bitmanip_zbe=0 -set=bitmanip_zbf=0 -set=bitmanip_zbp=0 -set=bitmanip_zbr=0 -set=bitmanip_zbs=0 -set=pic_total_int=1 -set=btb_enable=0 
# 
# To use this in a perf script, use 'require $RV_ROOT/configs/config.pl'
# Reference the hash via $config{name}..


%config = (
            'num_mmode_perf_regs' => '4',
            'dccm' => {
                        'dccm_sadr' => '0xf0040000',
                        'dccm_offset' => '0x40000',
                        'dccm_size' => 16,
                        'dccm_rows' => '2048',
                        'dccm_data_cell' => 'ram_2048x39',
                        'lsu_sb_bits' => 14,
                        'dccm_bits' => 14,
                        'dccm_reserved' => '0x1400',
                        'dccm_num_banks' => '2',
                        'dccm_ecc_width' => 7,
                        'dccm_index_bits' => 11,
                        'dccm_data_width' => 32,
                        'dccm_size_16' => '',
                        'dccm_byte_width' => '4',
                        'dccm_width_bits' => 2,
                        'dccm_bank_bits' => 1,
                        'dccm_num_banks_2' => '',
                        'dccm_eadr' => '0xf0043fff',
                        'dccm_region' => '0xf',
                        'dccm_fdata_width' => 39
                      },
            'btb' => {
                       'btb_btag_size' => 9,
                       'btb_array_depth' => 16,
                       'btb_index3_lo' => 10,
                       'btb_index3_hi' => 13,
                       'btb_toffset_size' => '12',
                       'btb_index2_hi' => 9,
                       'btb_index2_lo' => 6,
                       'btb_index1_lo' => '2',
                       'btb_addr_lo' => '2',
                       'btb_index1_hi' => 5,
                       'btb_fold2_index_hash' => 0,
                       'btb_addr_hi' => 5,
                       'btb_btag_fold' => 1,
                       'btb_size' => 32
                     },
            'triggers' => [
                            {
                              'reset' => [
                                           '0x23e00000',
                                           '0x00000000',
                                           '0x00000000'
                                         ],
                              'mask' => [
                                          '0x081818c7',
                                          '0xffffffff',
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
                            },
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
                            }
                          ],
            'protection' => {
                              'data_access_mask7' => '0xffffffff',
                              'inst_access_mask5' => '0xffffffff',
                              'inst_access_mask3' => '0xffffffff',
                              'inst_access_mask2' => '0xffffffff',
                              'inst_access_enable0' => '0x0',
                              'inst_access_mask1' => '0xffffffff',
                              'data_access_mask1' => '0xffffffff',
                              'data_access_enable0' => '0x0',
                              'data_access_mask2' => '0xffffffff',
                              'data_access_mask3' => '0xffffffff',
                              'inst_access_mask7' => '0xffffffff',
                              'data_access_mask5' => '0xffffffff',
                              'data_access_enable6' => '0x0',
                              'inst_access_addr4' => '0x00000000',
                              'data_access_addr0' => '0x00000000',
                              'data_access_mask6' => '0xffffffff',
                              'data_access_enable4' => '0x0',
                              'inst_access_enable4' => '0x0',
                              'inst_access_mask6' => '0xffffffff',
                              'inst_access_addr0' => '0x00000000',
                              'data_access_addr4' => '0x00000000',
                              'inst_access_enable6' => '0x0',
                              'data_access_mask0' => '0xffffffff',
                              'inst_access_mask4' => '0xffffffff',
                              'inst_access_enable2' => '0x0',
                              'data_access_enable1' => '0x0',
                              'data_access_addr6' => '0x00000000',
                              'inst_access_enable1' => '0x0',
                              'inst_access_addr6' => '0x00000000',
                              'data_access_enable2' => '0x0',
                              'data_access_mask4' => '0xffffffff',
                              'inst_access_mask0' => '0xffffffff',
                              'data_access_enable3' => '0x0',
                              'inst_access_addr2' => '0x00000000',
                              'pmp_entries' => '16',
                              'inst_access_addr3' => '0x00000000',
                              'inst_access_addr5' => '0x00000000',
                              'data_access_addr7' => '0x00000000',
                              'data_access_enable7' => '0x0',
                              'inst_access_enable5' => '0x0',
                              'inst_access_addr1' => '0x00000000',
                              'data_access_addr1' => '0x00000000',
                              'inst_access_enable7' => '0x0',
                              'data_access_enable5' => '0x0',
                              'data_access_addr5' => '0x00000000',
                              'inst_access_addr7' => '0x00000000',
                              'data_access_addr3' => '0x00000000',
                              'inst_access_enable3' => '0x0',
                              'data_access_addr2' => '0x00000000'
                            },
            'even_odd_trigger_chains' => 'true',
            'core' => {
                        'bitmanip_zbf' => 0,
                        'lsu_num_nbload_width' => '2',
                        'fast_interrupt_redirect' => 0,
                        'iccm_icache' => 'derived',
                        'div_new' => 1,
                        'bitmanip_zbc' => '0',
                        'lsu_stbuf_depth' => '4',
                        'lsu2dma' => 0,
                        'bitmanip_zba' => '0',
                        'icache_only' => 'derived',
                        'timer_legal_en' => '1',
                        'no_iccm_no_icache' => 1,
                        'bitmanip_zbe' => 0,
                        'div_bit' => '4',
                        'bitmanip_zbb' => '0',
                        'iccm_only' => 'derived',
                        'dma_buf_depth' => '5',
                        'lsu_num_nbload' => '4',
                        'bitmanip_zbp' => 0,
                        'bitmanip_zbr' => 0,
                        'bitmanip_zbs' => '0'
                      },
            'pic' => {
                       'pic_meip_offset' => '0x1000',
                       'pic_meigwclr_mask' => '0x0',
                       'pic_meipt_count' => 1,
                       'pic_base_addr' => '0xf00c0000',
                       'pic_meigwclr_offset' => '0x5000',
                       'pic_total_int' => 1,
                       'pic_meipt_mask' => '0x0',
                       'pic_meigwclr_count' => 1,
                       'pic_mpiccfg_count' => 1,
                       'pic_bits' => 15,
                       'pic_meie_count' => 1,
                       'pic_meie_mask' => '0x1',
                       'pic_meipl_mask' => '0xf',
                       'pic_meigwctrl_mask' => '0x3',
                       'pic_mpiccfg_offset' => '0x3000',
                       'pic_size' => 32,
                       'pic_meigwctrl_offset' => '0x4000',
                       'pic_meipl_count' => 1,
                       'pic_meipl_offset' => '0x0000',
                       'pic_total_int_plus1' => 2,
                       'pic_meie_offset' => '0x2000',
                       'pic_region' => '0xf',
                       'pic_meigwctrl_count' => 1,
                       'pic_meipt_offset' => '0x3004',
                       'pic_meip_mask' => '0x0',
                       'pic_int_words' => 0,
                       'pic_offset' => '0xc0000',
                       'pic_mpiccfg_mask' => '0x1',
                       'pic_meip_count' => 0
                     },
            'iccm' => {
                        'iccm_data_cell' => 'ram_4096x39',
                        'iccm_index_bits' => 12,
                        'iccm_ecc_width' => '7',
                        'iccm_bits' => 16,
                        'iccm_reserved' => '0x1000',
                        'iccm_bank_index_lo' => 4,
                        'iccm_num_banks' => '4',
                        'iccm_size_64' => '',
                        'iccm_offset' => '0xe000000',
                        'iccm_rows' => '4096',
                        'iccm_size' => 64,
                        'iccm_sadr' => '0xee000000',
                        'iccm_region' => '0xe',
                        'iccm_bank_hi' => 3,
                        'iccm_bank_bits' => 2,
                        'iccm_eadr' => '0xee00ffff',
                        'iccm_num_banks_4' => ''
                      },
            'icache' => {
                          'icache_scnd_last' => 6,
                          'icache_bank_bits' => 1,
                          'icache_bank_hi' => 3,
                          'icache_beat_bits' => 3,
                          'icache_bank_width' => 8,
                          'icache_data_cell' => 'ram_512x71',
                          'icache_num_lines_way' => '128',
                          'icache_fdata_width' => 71,
                          'icache_waypack' => '1',
                          'icache_num_beats' => 8,
                          'icache_bypass_enable' => '1',
                          'icache_tag_num_bypass_width' => 2,
                          'icache_tag_bypass_enable' => '1',
                          'icache_num_bypass_width' => 2,
                          'icache_status_bits' => 1,
                          'icache_banks_way' => 2,
                          'icache_tag_cell' => 'ram_128x25',
                          'icache_num_ways' => 2,
                          'icache_num_lines_bank' => '64',
                          'icache_ecc' => '1',
                          'icache_index_hi' => 12,
                          'icache_data_depth' => '512',
                          'icache_bank_lo' => 3,
                          'icache_data_index_lo' => 4,
                          'icache_num_bypass' => '2',
                          'icache_beat_addr_hi' => 5,
                          'icache_data_width' => 64,
                          'icache_2banks' => '1',
                          'icache_size' => 16,
                          'icache_tag_lo' => 13,
                          'icache_tag_depth' => 128,
                          'icache_tag_index_lo' => '6',
                          'icache_tag_num_bypass' => '2',
                          'icache_ln_sz' => 64,
                          'icache_num_lines' => 256
                        },
            'numiregs' => '32',
            'tec_rv_icg' => 'clockhdr',
            'harts' => 1,
            'target' => 'typical_pd',
            'xlen' => 32,
            'bus' => {
                       'lsu_bus_prty' => '2',
                       'dma_bus_tag' => '1',
                       'ifu_bus_id' => '1',
                       'dma_bus_prty' => '2',
                       'sb_bus_tag' => '1',
                       'lsu_bus_tag' => 3,
                       'bus_prty_default' => '3',
                       'sb_bus_prty' => '2',
                       'sb_bus_id' => '1',
                       'lsu_bus_id' => '1',
                       'ifu_bus_prty' => '2',
                       'dma_bus_id' => '1',
                       'ifu_bus_tag' => '3'
                     },
            'user_ec_rv_icg' => 'user_clock_gate',
            'max_mmode_perf_event' => '516',
            'reset_vec' => '0x80000000',
            'regwidth' => '32',
            'csr' => {
                       'instret' => {
                                      'exists' => 'false'
                                    },
                       'mitcnt1' => {
                                      'exists' => 'true',
                                      'reset' => '0x0',
                                      'number' => '0x7d5',
                                      'mask' => '0xffffffff'
                                    },
                       'meicidpl' => {
                                       'reset' => '0x0',
                                       'number' => '0xbcb',
                                       'mask' => '0xf',
                                       'comment' => 'External interrupt claim id priority level.',
                                       'exists' => 'true'
                                     },
                       'dicawics' => {
                                       'reset' => '0x0',
                                       'number' => '0x7c8',
                                       'mask' => '0x0130fffc',
                                       'comment' => 'Cache diagnostics.',
                                       'exists' => 'true',
                                       'debug' => 'true'
                                     },
                       'mhpmcounter3h' => {
                                            'exists' => 'true',
                                            'mask' => '0xffffffff',
                                            'reset' => '0x0'
                                          },
                       'mitbnd1' => {
                                      'reset' => '0xffffffff',
                                      'number' => '0x7d6',
                                      'mask' => '0xffffffff',
                                      'exists' => 'true'
                                    },
                       'mhpmcounter4h' => {
                                            'exists' => 'true',
                                            'reset' => '0x0',
                                            'mask' => '0xffffffff'
                                          },
                       'mvendorid' => {
                                        'exists' => 'true',
                                        'reset' => '0x45',
                                        'mask' => '0x0'
                                      },
                       'mdccmect' => {
                                       'reset' => '0x0',
                                       'number' => '0x7f2',
                                       'mask' => '0xffffffff',
                                       'exists' => 'true'
                                     },
                       'mhpmevent3' => {
                                         'exists' => 'true',
                                         'reset' => '0x0',
                                         'mask' => '0xffffffff'
                                       },
                       'meicurpl' => {
                                       'exists' => 'true',
                                       'comment' => 'External interrupt current priority level.',
                                       'number' => '0xbcc',
                                       'mask' => '0xf',
                                       'reset' => '0x0'
                                     },
                       'mpmc' => {
                                   'exists' => 'true',
                                   'mask' => '0x2',
                                   'number' => '0x7c6',
                                   'reset' => '0x2'
                                 },
                       'misa' => {
                                   'mask' => '0x0',
                                   'reset' => '0x40001104',
                                   'exists' => 'true'
                                 },
                       'mitctl1' => {
                                      'exists' => 'true',
                                      'number' => '0x7d7',
                                      'mask' => '0x0000000f',
                                      'reset' => '0x1'
                                    },
                       'mfdhs' => {
                                    'comment' => 'Force Debug Halt Status',
                                    'exists' => 'true',
                                    'number' => '0x7cf',
                                    'mask' => '0x00000003',
                                    'reset' => '0x0'
                                  },
                       'dicago' => {
                                     'debug' => 'true',
                                     'comment' => 'Cache diagnostics.',
                                     'exists' => 'true',
                                     'number' => '0x7cb',
                                     'mask' => '0x0',
                                     'reset' => '0x0'
                                   },
                       'mhpmcounter5' => {
                                           'exists' => 'true',
                                           'mask' => '0xffffffff',
                                           'reset' => '0x0'
                                         },
                       'cycle' => {
                                    'exists' => 'false'
                                  },
                       'mhpmcounter6h' => {
                                            'exists' => 'true',
                                            'reset' => '0x0',
                                            'mask' => '0xffffffff'
                                          },
                       'dcsr' => {
                                   'reset' => '0x40000003',
                                   'mask' => '0x00008c04',
                                   'exists' => 'true',
                                   'poke_mask' => '0x00008dcc',
                                   'debug' => 'true'
                                 },
                       'mfdht' => {
                                    'reset' => '0x0',
                                    'mask' => '0x0000003f',
                                    'comment' => 'Force Debug Halt Threshold',
                                    'shared' => 'true',
                                    'number' => '0x7ce',
                                    'exists' => 'true'
                                  },
                       'mcpc' => {
                                   'exists' => 'true',
                                   'comment' => 'Core pause',
                                   'reset' => '0x0',
                                   'number' => '0x7c2',
                                   'mask' => '0x0'
                                 },
                       'mip' => {
                                  'mask' => '0x0',
                                  'reset' => '0x0',
                                  'poke_mask' => '0x70000888',
                                  'exists' => 'true'
                                },
                       'miccmect' => {
                                       'exists' => 'true',
                                       'reset' => '0x0',
                                       'number' => '0x7f1',
                                       'mask' => '0xffffffff'
                                     },
                       'micect' => {
                                     'mask' => '0xffffffff',
                                     'number' => '0x7f0',
                                     'reset' => '0x0',
                                     'exists' => 'true'
                                   },
                       'meicpct' => {
                                      'comment' => 'External claim id/priority capture.',
                                      'exists' => 'true',
                                      'number' => '0xbca',
                                      'mask' => '0x0',
                                      'reset' => '0x0'
                                    },
                       'dmst' => {
                                   'exists' => 'true',
                                   'comment' => 'Memory synch trigger: Flush caches in debug mode.',
                                   'debug' => 'true',
                                   'reset' => '0x0',
                                   'mask' => '0x0',
                                   'number' => '0x7c4'
                                 },
                       'mstatus' => {
                                      'exists' => 'true',
                                      'reset' => '0x1800',
                                      'mask' => '0x88'
                                    },
                       'mimpid' => {
                                     'exists' => 'true',
                                     'mask' => '0x0',
                                     'reset' => '0x4'
                                   },
                       'marchid' => {
                                      'exists' => 'true',
                                      'mask' => '0x0',
                                      'reset' => '0x00000010'
                                    },
                       'mhpmcounter5h' => {
                                            'exists' => 'true',
                                            'reset' => '0x0',
                                            'mask' => '0xffffffff'
                                          },
                       'mitbnd0' => {
                                      'exists' => 'true',
                                      'reset' => '0xffffffff',
                                      'number' => '0x7d3',
                                      'mask' => '0xffffffff'
                                    },
                       'mcounteren' => {
                                         'exists' => 'false'
                                       },
                       'mhpmcounter6' => {
                                           'exists' => 'true',
                                           'mask' => '0xffffffff',
                                           'reset' => '0x0'
                                         },
                       'mitcnt0' => {
                                      'reset' => '0x0',
                                      'number' => '0x7d2',
                                      'mask' => '0xffffffff',
                                      'exists' => 'true'
                                    },
                       'mhartid' => {
                                      'reset' => '0x0',
                                      'mask' => '0x0',
                                      'exists' => 'true',
                                      'poke_mask' => '0xfffffff0'
                                    },
                       'meipt' => {
                                    'comment' => 'External interrupt priority threshold.',
                                    'exists' => 'true',
                                    'reset' => '0x0',
                                    'number' => '0xbc9',
                                    'mask' => '0xf'
                                  },
                       'mhpmevent4' => {
                                         'exists' => 'true',
                                         'reset' => '0x0',
                                         'mask' => '0xffffffff'
                                       },
                       'mitctl0' => {
                                      'mask' => '0x00000007',
                                      'number' => '0x7d4',
                                      'reset' => '0x1',
                                      'exists' => 'true'
                                    },
                       'mscause' => {
                                      'exists' => 'true',
                                      'mask' => '0x0000000f',
                                      'number' => '0x7ff',
                                      'reset' => '0x0'
                                    },
                       'mcgc' => {
                                   'exists' => 'true',
                                   'poke_mask' => '0x000003ff',
                                   'reset' => '0x200',
                                   'number' => '0x7f8',
                                   'mask' => '0x000003ff'
                                 },
                       'mcountinhibit' => {
                                            'commnet' => 'Performance counter inhibit. One bit per counter.',
                                            'exists' => 'true',
                                            'poke_mask' => '0x7d',
                                            'reset' => '0x0',
                                            'mask' => '0x7d'
                                          },
                       'mrac' => {
                                   'comment' => 'Memory region io and cache control.',
                                   'mask' => '0xffffffff',
                                   'reset' => '0x0',
                                   'exists' => 'true',
                                   'number' => '0x7c0',
                                   'shared' => 'true'
                                 },
                       'mhpmcounter4' => {
                                           'reset' => '0x0',
                                           'mask' => '0xffffffff',
                                           'exists' => 'true'
                                         },
                       'mie' => {
                                  'reset' => '0x0',
                                  'mask' => '0x70000888',
                                  'exists' => 'true'
                                },
                       'dicad0' => {
                                     'number' => '0x7c9',
                                     'mask' => '0xffffffff',
                                     'reset' => '0x0',
                                     'debug' => 'true',
                                     'exists' => 'true',
                                     'comment' => 'Cache diagnostics.'
                                   },
                       'mhpmevent5' => {
                                         'exists' => 'true',
                                         'mask' => '0xffffffff',
                                         'reset' => '0x0'
                                       },
                       'mhpmcounter3' => {
                                           'exists' => 'true',
                                           'mask' => '0xffffffff',
                                           'reset' => '0x0'
                                         },
                       'dicad1' => {
                                     'mask' => '0x3',
                                     'number' => '0x7ca',
                                     'reset' => '0x0',
                                     'debug' => 'true',
                                     'comment' => 'Cache diagnostics.',
                                     'exists' => 'true'
                                   },
                       'tselect' => {
                                      'exists' => 'true',
                                      'reset' => '0x0',
                                      'mask' => '0x3'
                                    },
                       'time' => {
                                   'exists' => 'false'
                                 },
                       'mfdc' => {
                                   'mask' => '0x00071fff',
                                   'number' => '0x7f9',
                                   'reset' => '0x00070040',
                                   'exists' => 'true'
                                 },
                       'mhpmevent6' => {
                                         'exists' => 'true',
                                         'reset' => '0x0',
                                         'mask' => '0xffffffff'
                                       }
                     },
            'bht' => {
                       'bht_addr_hi' => 7,
                       'bht_size' => 128,
                       'bht_ghr_size' => 6,
                       'bht_ghr_hash_1' => 1,
                       'bht_addr_lo' => '2',
                       'bht_ghr_range' => '5:0',
                       'bht_array_depth' => 64,
                       'bht_hash_string' => '{ghr[5:4], hashin[5:2]^ghr[4-1:0]} // cf1'
                     },
            'nmi_vec' => '0x11110000',
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
            'memmap' => {
                          'consoleio' => '0xd0580000',
                          'serialio' => '0xd0580000',
                          'unused_region7' => '0x10000000',
                          'unused_region4' => '0x40000000',
                          'unused_region1' => '0x70000000',
                          'unused_region6' => '0x20000000',
                          'external_data_1' => '0xb0000000',
                          'unused_region3' => '0x50000000',
                          'unused_region2' => '0x60000000',
                          'unused_region5' => '0x30000000',
                          'unused_region0' => '0x90000000',
                          'debug_sb_mem' => '0xa0580000',
                          'unused_region8' => '0x00000000',
                          'external_data' => '0xc0580000'
                        },
            'retstack' => {
                            'ret_stack_size' => '2'
                          },
            'testbench' => {
                             'build_axi_native' => 1,
                             'CPU_TOP' => '`RV_TOP.veer',
                             'TOP' => 'tb_top',
                             'build_axi4' => 1,
                             'ext_addrwidth' => '32',
                             'ext_datawidth' => '64',
                             'sterr_rollback' => '0',
                             'RV_TOP' => '`TOP.rvtop_wrapper.rvtop',
                             'SDVT_AHB' => 0,
                             'clock_period' => '100',
                             'lderr_rollback' => '1'
                           },
            'config_key' => '32\'hdeadbeef',
            'physical' => '1'
          );
1;
