#  Copyright 2019-2026 Western Digital Corporation or its affiliates.
#  Copyright 2022-2026 Antmicro <www.antmicro.com>
# 
#  SPDX-License-Identifier: Apache-2.0
#  Licensed under the Apache License, Version 2.0, see LICENSE for details.
# 
#  This is an automatically generated file by dwitisuchak on Tue Nov 10 01:37:00 IST 2026
# 
#  cmd:    veer -target=typical_pd -fpga_optimize=0 -set=icache_enable=0 -set=user_mode=0 -set=lockstep_enable=0 -set=bitmanip_zba=0 -set=bitmanip_zbb=0 -set=bitmanip_zbc=0 -set=bitmanip_zbe=0 -set=bitmanip_zbf=0 -set=bitmanip_zbp=0 -set=bitmanip_zbr=0 -set=bitmanip_zbs=0 -set=pic_total_int=1 -set=iccm_enable=0 -set=dccm_enable=0 
# 
# To use this in a perf script, use 'require $RV_ROOT/configs/config.pl'
# Reference the hash via $config{name}..


%config = (
            'btb' => {
                       'btb_addr_lo' => '2',
                       'btb_index2_hi' => 9,
                       'btb_index3_hi' => 13,
                       'btb_enable' => '1',
                       'btb_array_depth' => 16,
                       'btb_size' => 32,
                       'btb_index1_lo' => '2',
                       'btb_btag_fold' => 1,
                       'btb_fold2_index_hash' => 0,
                       'btb_btag_size' => 9,
                       'btb_index3_lo' => 10,
                       'btb_index2_lo' => 6,
                       'btb_addr_hi' => 5,
                       'btb_index1_hi' => 5,
                       'btb_toffset_size' => '12'
                     },
            'triggers' => [
                            {
                              'mask' => [
                                          '0x081818c7',
                                          '0xffffffff',
                                          '0x00000000'
                                        ],
                              'poke_mask' => [
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
            'pic' => {
                       'pic_meigwclr_offset' => '0x5000',
                       'pic_meipt_count' => 1,
                       'pic_meie_offset' => '0x2000',
                       'pic_meipt_offset' => '0x3004',
                       'pic_total_int_plus1' => 2,
                       'pic_region' => '0xf',
                       'pic_base_addr' => '0xf00c0000',
                       'pic_mpiccfg_offset' => '0x3000',
                       'pic_meigwclr_mask' => '0x0',
                       'pic_meip_offset' => '0x1000',
                       'pic_meipt_mask' => '0x0',
                       'pic_size' => 32,
                       'pic_mpiccfg_mask' => '0x1',
                       'pic_meigwctrl_count' => 1,
                       'pic_meipl_mask' => '0xf',
                       'pic_meigwctrl_offset' => '0x4000',
                       'pic_meip_mask' => '0x0',
                       'pic_meie_count' => 1,
                       'pic_meigwctrl_mask' => '0x3',
                       'pic_offset' => '0xc0000',
                       'pic_mpiccfg_count' => 1,
                       'pic_meipl_count' => 1,
                       'pic_meigwclr_count' => 1,
                       'pic_total_int' => 1,
                       'pic_bits' => 15,
                       'pic_int_words' => 0,
                       'pic_meie_mask' => '0x1',
                       'pic_meip_count' => 0,
                       'pic_meipl_offset' => '0x0000'
                     },
            'memmap' => {
                          'unused_region4' => '0x40000000',
                          'unused_region8' => '0x00000000',
                          'unused_region0' => '0x90000000',
                          'unused_region1' => '0x70000000',
                          'external_data_1' => '0xb0000000',
                          'unused_region2' => '0x60000000',
                          'external_data' => '0xc0580000',
                          'unused_region7' => '0x10000000',
                          'unused_region5' => '0x30000000',
                          'unused_region3' => '0x50000000',
                          'debug_sb_mem' => '0xa0580000',
                          'unused_region6' => '0x20000000',
                          'consoleio' => '0xd0580000',
                          'serialio' => '0xd0580000'
                        },
            'target' => 'typical_pd',
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
            'numiregs' => '32',
            'physical' => '1',
            'config_key' => '32\'hdeadbeef',
            'csr' => {
                       'mitcnt1' => {
                                      'mask' => '0xffffffff',
                                      'reset' => '0x0',
                                      'number' => '0x7d5',
                                      'exists' => 'true'
                                    },
                       'dicad0' => {
                                     'exists' => 'true',
                                     'comment' => 'Cache diagnostics.',
                                     'reset' => '0x0',
                                     'mask' => '0xffffffff',
                                     'number' => '0x7c9',
                                     'debug' => 'true'
                                   },
                       'mhpmevent5' => {
                                         'mask' => '0xffffffff',
                                         'reset' => '0x0',
                                         'exists' => 'true'
                                       },
                       'mfdhs' => {
                                    'mask' => '0x00000003',
                                    'reset' => '0x0',
                                    'comment' => 'Force Debug Halt Status',
                                    'number' => '0x7cf',
                                    'exists' => 'true'
                                  },
                       'dmst' => {
                                   'number' => '0x7c4',
                                   'debug' => 'true',
                                   'exists' => 'true',
                                   'comment' => 'Memory synch trigger: Flush caches in debug mode.',
                                   'reset' => '0x0',
                                   'mask' => '0x0'
                                 },
                       'mitbnd0' => {
                                      'reset' => '0xffffffff',
                                      'mask' => '0xffffffff',
                                      'number' => '0x7d3',
                                      'exists' => 'true'
                                    },
                       'mhpmcounter6' => {
                                           'exists' => 'true',
                                           'reset' => '0x0',
                                           'mask' => '0xffffffff'
                                         },
                       'dcsr' => {
                                   'mask' => '0x00008c04',
                                   'debug' => 'true',
                                   'poke_mask' => '0x00008dcc',
                                   'reset' => '0x40000003',
                                   'exists' => 'true'
                                 },
                       'mvendorid' => {
                                        'reset' => '0x45',
                                        'mask' => '0x0',
                                        'exists' => 'true'
                                      },
                       'miccmect' => {
                                       'exists' => 'true',
                                       'number' => '0x7f1',
                                       'mask' => '0xffffffff',
                                       'reset' => '0x0'
                                     },
                       'dicad1' => {
                                     'mask' => '0x3',
                                     'reset' => '0x0',
                                     'exists' => 'true',
                                     'comment' => 'Cache diagnostics.',
                                     'debug' => 'true',
                                     'number' => '0x7ca'
                                   },
                       'meicurpl' => {
                                       'number' => '0xbcc',
                                       'exists' => 'true',
                                       'comment' => 'External interrupt current priority level.',
                                       'mask' => '0xf',
                                       'reset' => '0x0'
                                     },
                       'meicidpl' => {
                                       'comment' => 'External interrupt claim id priority level.',
                                       'exists' => 'true',
                                       'number' => '0xbcb',
                                       'reset' => '0x0',
                                       'mask' => '0xf'
                                     },
                       'mip' => {
                                  'exists' => 'true',
                                  'reset' => '0x0',
                                  'poke_mask' => '0x70000888',
                                  'mask' => '0x0'
                                },
                       'instret' => {
                                      'exists' => 'false'
                                    },
                       'mcountinhibit' => {
                                            'commnet' => 'Performance counter inhibit. One bit per counter.',
                                            'exists' => 'true',
                                            'poke_mask' => '0x7d',
                                            'mask' => '0x7d',
                                            'reset' => '0x0'
                                          },
                       'meicpct' => {
                                      'reset' => '0x0',
                                      'mask' => '0x0',
                                      'comment' => 'External claim id/priority capture.',
                                      'exists' => 'true',
                                      'number' => '0xbca'
                                    },
                       'mhpmcounter6h' => {
                                            'exists' => 'true',
                                            'reset' => '0x0',
                                            'mask' => '0xffffffff'
                                          },
                       'mimpid' => {
                                     'reset' => '0x4',
                                     'mask' => '0x0',
                                     'exists' => 'true'
                                   },
                       'mitctl1' => {
                                      'mask' => '0x0000000f',
                                      'reset' => '0x1',
                                      'number' => '0x7d7',
                                      'exists' => 'true'
                                    },
                       'mcounteren' => {
                                         'exists' => 'false'
                                       },
                       'mcgc' => {
                                   'exists' => 'true',
                                   'number' => '0x7f8',
                                   'reset' => '0x200',
                                   'poke_mask' => '0x000003ff',
                                   'mask' => '0x000003ff'
                                 },
                       'micect' => {
                                     'mask' => '0xffffffff',
                                     'reset' => '0x0',
                                     'exists' => 'true',
                                     'number' => '0x7f0'
                                   },
                       'misa' => {
                                   'mask' => '0x0',
                                   'reset' => '0x40001104',
                                   'exists' => 'true'
                                 },
                       'mhpmevent3' => {
                                         'reset' => '0x0',
                                         'mask' => '0xffffffff',
                                         'exists' => 'true'
                                       },
                       'mstatus' => {
                                      'exists' => 'true',
                                      'reset' => '0x1800',
                                      'mask' => '0x88'
                                    },
                       'mfdc' => {
                                   'number' => '0x7f9',
                                   'exists' => 'true',
                                   'reset' => '0x00070040',
                                   'mask' => '0x00071fff'
                                 },
                       'meipt' => {
                                    'reset' => '0x0',
                                    'mask' => '0xf',
                                    'comment' => 'External interrupt priority threshold.',
                                    'number' => '0xbc9',
                                    'exists' => 'true'
                                  },
                       'mhpmcounter5' => {
                                           'exists' => 'true',
                                           'reset' => '0x0',
                                           'mask' => '0xffffffff'
                                         },
                       'mhpmcounter3' => {
                                           'reset' => '0x0',
                                           'mask' => '0xffffffff',
                                           'exists' => 'true'
                                         },
                       'dicago' => {
                                     'debug' => 'true',
                                     'number' => '0x7cb',
                                     'mask' => '0x0',
                                     'reset' => '0x0',
                                     'exists' => 'true',
                                     'comment' => 'Cache diagnostics.'
                                   },
                       'mrac' => {
                                   'comment' => 'Memory region io and cache control.',
                                   'exists' => 'true',
                                   'mask' => '0xffffffff',
                                   'reset' => '0x0',
                                   'number' => '0x7c0',
                                   'shared' => 'true'
                                 },
                       'tselect' => {
                                      'reset' => '0x0',
                                      'mask' => '0x3',
                                      'exists' => 'true'
                                    },
                       'mie' => {
                                  'exists' => 'true',
                                  'mask' => '0x70000888',
                                  'reset' => '0x0'
                                },
                       'mhpmcounter4h' => {
                                            'reset' => '0x0',
                                            'mask' => '0xffffffff',
                                            'exists' => 'true'
                                          },
                       'mscause' => {
                                      'mask' => '0x0000000f',
                                      'reset' => '0x0',
                                      'exists' => 'true',
                                      'number' => '0x7ff'
                                    },
                       'mitcnt0' => {
                                      'number' => '0x7d2',
                                      'exists' => 'true',
                                      'reset' => '0x0',
                                      'mask' => '0xffffffff'
                                    },
                       'mhpmevent6' => {
                                         'reset' => '0x0',
                                         'mask' => '0xffffffff',
                                         'exists' => 'true'
                                       },
                       'mitbnd1' => {
                                      'exists' => 'true',
                                      'number' => '0x7d6',
                                      'reset' => '0xffffffff',
                                      'mask' => '0xffffffff'
                                    },
                       'mhpmevent4' => {
                                         'exists' => 'true',
                                         'reset' => '0x0',
                                         'mask' => '0xffffffff'
                                       },
                       'marchid' => {
                                      'reset' => '0x00000010',
                                      'mask' => '0x0',
                                      'exists' => 'true'
                                    },
                       'mfdht' => {
                                    'comment' => 'Force Debug Halt Threshold',
                                    'exists' => 'true',
                                    'reset' => '0x0',
                                    'mask' => '0x0000003f',
                                    'number' => '0x7ce',
                                    'shared' => 'true'
                                  },
                       'mhpmcounter5h' => {
                                            'exists' => 'true',
                                            'mask' => '0xffffffff',
                                            'reset' => '0x0'
                                          },
                       'mpmc' => {
                                   'number' => '0x7c6',
                                   'exists' => 'true',
                                   'mask' => '0x2',
                                   'reset' => '0x2'
                                 },
                       'mhpmcounter4' => {
                                           'mask' => '0xffffffff',
                                           'reset' => '0x0',
                                           'exists' => 'true'
                                         },
                       'mhpmcounter3h' => {
                                            'reset' => '0x0',
                                            'mask' => '0xffffffff',
                                            'exists' => 'true'
                                          },
                       'mcpc' => {
                                   'number' => '0x7c2',
                                   'exists' => 'true',
                                   'comment' => 'Core pause',
                                   'reset' => '0x0',
                                   'mask' => '0x0'
                                 },
                       'dicawics' => {
                                       'exists' => 'true',
                                       'comment' => 'Cache diagnostics.',
                                       'mask' => '0x0130fffc',
                                       'reset' => '0x0',
                                       'number' => '0x7c8',
                                       'debug' => 'true'
                                     },
                       'time' => {
                                   'exists' => 'false'
                                 },
                       'mdccmect' => {
                                       'number' => '0x7f2',
                                       'exists' => 'true',
                                       'mask' => '0xffffffff',
                                       'reset' => '0x0'
                                     },
                       'cycle' => {
                                    'exists' => 'false'
                                  },
                       'mitctl0' => {
                                      'exists' => 'true',
                                      'number' => '0x7d4',
                                      'reset' => '0x1',
                                      'mask' => '0x00000007'
                                    },
                       'mhartid' => {
                                      'reset' => '0x0',
                                      'poke_mask' => '0xfffffff0',
                                      'mask' => '0x0',
                                      'exists' => 'true'
                                    }
                     },
            'bht' => {
                       'bht_size' => 128,
                       'bht_ghr_hash_1' => 1,
                       'bht_ghr_size' => 6,
                       'bht_array_depth' => 64,
                       'bht_addr_hi' => 7,
                       'bht_hash_string' => '{ghr[5:4], hashin[5:2]^ghr[4-1:0]} // cf1',
                       'bht_ghr_range' => '5:0',
                       'bht_addr_lo' => '2'
                     },
            'num_mmode_perf_regs' => '4',
            'regwidth' => '32',
            'bus' => {
                       'ifu_bus_id' => '1',
                       'dma_bus_prty' => '2',
                       'sb_bus_prty' => '2',
                       'bus_prty_default' => '3',
                       'ifu_bus_tag' => '3',
                       'lsu_bus_prty' => '2',
                       'sb_bus_id' => '1',
                       'lsu_bus_tag' => 3,
                       'ifu_bus_prty' => '2',
                       'dma_bus_id' => '1',
                       'dma_bus_tag' => '1',
                       'lsu_bus_id' => '1',
                       'sb_bus_tag' => '1'
                     },
            'dccm' => {
                        'dccm_region' => '0xf',
                        'lsu_sb_bits' => 14,
                        'dccm_byte_width' => '4',
                        'dccm_num_banks' => '2',
                        'dccm_bits' => 14,
                        'dccm_fdata_width' => 39,
                        'dccm_size' => 16,
                        'dccm_offset' => '0x40000',
                        'dccm_width_bits' => 2,
                        'dccm_num_banks_2' => '',
                        'dccm_index_bits' => 11,
                        'dccm_data_width' => 32,
                        'dccm_reserved' => '0x1400',
                        'dccm_size_16' => '',
                        'dccm_rows' => '2048',
                        'dccm_bank_bits' => 1,
                        'dccm_sadr' => '0xf0040000',
                        'dccm_ecc_width' => 7,
                        'dccm_data_cell' => 'ram_2048x39',
                        'dccm_eadr' => '0xf0043fff'
                      },
            'tec_rv_icg' => 'clockhdr',
            'nmi_vec' => '0x11110000',
            'retstack' => {
                            'ret_stack_size' => '2'
                          },
            'harts' => 1,
            'testbench' => {
                             'RV_TOP' => '`TOP.rvtop_wrapper.rvtop',
                             'SDVT_AHB' => 0,
                             'lderr_rollback' => '1',
                             'TOP' => 'tb_top',
                             'ext_addrwidth' => '32',
                             'clock_period' => '100',
                             'CPU_TOP' => '`RV_TOP.veer',
                             'build_axi4' => 1,
                             'ext_datawidth' => '64',
                             'build_axi_native' => 1,
                             'sterr_rollback' => '0'
                           },
            'xlen' => 32,
            'protection' => {
                              'data_access_mask7' => '0xffffffff',
                              'data_access_addr6' => '0x00000000',
                              'inst_access_addr5' => '0x00000000',
                              'data_access_enable1' => '0x0',
                              'data_access_mask5' => '0xffffffff',
                              'data_access_enable2' => '0x0',
                              'data_access_enable3' => '0x0',
                              'inst_access_mask6' => '0xffffffff',
                              'inst_access_addr7' => '0x00000000',
                              'inst_access_enable0' => '0x0',
                              'data_access_enable6' => '0x0',
                              'inst_access_mask5' => '0xffffffff',
                              'inst_access_enable1' => '0x0',
                              'inst_access_enable2' => '0x0',
                              'inst_access_enable3' => '0x0',
                              'data_access_addr7' => '0x00000000',
                              'data_access_enable0' => '0x0',
                              'inst_access_enable6' => '0x0',
                              'data_access_mask6' => '0xffffffff',
                              'inst_access_addr6' => '0x00000000',
                              'inst_access_mask7' => '0xffffffff',
                              'data_access_addr5' => '0x00000000',
                              'inst_access_enable5' => '0x0',
                              'pmp_entries' => '16',
                              'data_access_addr0' => '0x00000000',
                              'data_access_mask1' => '0xffffffff',
                              'data_access_mask2' => '0xffffffff',
                              'inst_access_enable4' => '0x0',
                              'inst_access_addr3' => '0x00000000',
                              'inst_access_enable7' => '0x0',
                              'data_access_mask4' => '0xffffffff',
                              'inst_access_addr2' => '0x00000000',
                              'inst_access_addr4' => '0x00000000',
                              'data_access_mask3' => '0xffffffff',
                              'inst_access_addr1' => '0x00000000',
                              'inst_access_mask0' => '0xffffffff',
                              'data_access_addr2' => '0x00000000',
                              'inst_access_mask3' => '0xffffffff',
                              'data_access_addr4' => '0x00000000',
                              'data_access_mask0' => '0xffffffff',
                              'data_access_addr1' => '0x00000000',
                              'data_access_enable5' => '0x0',
                              'inst_access_mask1' => '0xffffffff',
                              'inst_access_addr0' => '0x00000000',
                              'inst_access_mask2' => '0xffffffff',
                              'data_access_enable4' => '0x0',
                              'inst_access_mask4' => '0xffffffff',
                              'data_access_addr3' => '0x00000000',
                              'data_access_enable7' => '0x0'
                            },
            'core' => {
                        'bitmanip_zba' => '0',
                        'lsu_num_nbload' => '4',
                        'bitmanip_zbs' => '0',
                        'bitmanip_zbf' => 0,
                        'bitmanip_zbe' => 0,
                        'iccm_only' => 'derived',
                        'icache_only' => 'derived',
                        'lsu2dma' => 0,
                        'div_new' => 1,
                        'div_bit' => '4',
                        'bitmanip_zbb' => '0',
                        'no_iccm_no_icache' => 1,
                        'bitmanip_zbr' => 0,
                        'bitmanip_zbc' => '0',
                        'lsu_stbuf_depth' => '4',
                        'iccm_icache' => 'derived',
                        'timer_legal_en' => '1',
                        'dma_buf_depth' => '5',
                        'bitmanip_zbp' => 0,
                        'lsu_num_nbload_width' => '2',
                        'fast_interrupt_redirect' => 0
                      },
            'even_odd_trigger_chains' => 'true',
            'icache' => {
                          'icache_num_lines_bank' => '64',
                          'icache_bank_bits' => 1,
                          'icache_scnd_last' => 6,
                          'icache_tag_num_bypass_width' => 2,
                          'icache_num_ways' => 2,
                          'icache_num_lines' => 256,
                          'icache_data_cell' => 'ram_512x71',
                          'icache_tag_index_lo' => '6',
                          'icache_tag_num_bypass' => '2',
                          'icache_ecc' => '1',
                          'icache_data_width' => 64,
                          'icache_bank_width' => 8,
                          'icache_size' => 16,
                          'icache_tag_depth' => 128,
                          'icache_status_bits' => 1,
                          'icache_tag_cell' => 'ram_128x25',
                          'icache_num_bypass' => '2',
                          'icache_2banks' => '1',
                          'icache_waypack' => '1',
                          'icache_beat_addr_hi' => 5,
                          'icache_tag_lo' => 13,
                          'icache_data_depth' => '512',
                          'icache_ln_sz' => 64,
                          'icache_bypass_enable' => '1',
                          'icache_num_bypass_width' => 2,
                          'icache_banks_way' => 2,
                          'icache_num_lines_way' => '128',
                          'icache_data_index_lo' => 4,
                          'icache_bank_hi' => 3,
                          'icache_tag_bypass_enable' => '1',
                          'icache_fdata_width' => 71,
                          'icache_num_beats' => 8,
                          'icache_bank_lo' => 3,
                          'icache_index_hi' => 12,
                          'icache_beat_bits' => 3
                        },
            'user_ec_rv_icg' => 'user_clock_gate',
            'iccm' => {
                        'iccm_num_banks' => '4',
                        'iccm_size_64' => '',
                        'iccm_region' => '0xe',
                        'iccm_offset' => '0xe000000',
                        'iccm_size' => 64,
                        'iccm_bits' => 16,
                        'iccm_index_bits' => 12,
                        'iccm_bank_index_lo' => 4,
                        'iccm_reserved' => '0x1000',
                        'iccm_bank_hi' => 3,
                        'iccm_bank_bits' => 2,
                        'iccm_rows' => '4096',
                        'iccm_ecc_width' => '7',
                        'iccm_sadr' => '0xee000000',
                        'iccm_num_banks_4' => '',
                        'iccm_eadr' => '0xee00ffff',
                        'iccm_data_cell' => 'ram_4096x39'
                      },
            'max_mmode_perf_event' => '516',
            'reset_vec' => '0x80000000'
          );
1;
