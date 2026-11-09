#  Copyright 2019-2026 Western Digital Corporation or its affiliates.
#  Copyright 2022-2026 Antmicro <www.antmicro.com>
# 
#  SPDX-License-Identifier: Apache-2.0
#  Licensed under the Apache License, Version 2.0, see LICENSE for details.
# 
#  This is an automatically generated file by dwitisuchak on Tue Nov 10 01:37:00 IST 2026
# 
#  cmd:    veer -target=typical_pd -fpga_optimize=0 -set=icache_enable=0 -set=user_mode=0 -set=lockstep_enable=0 -set=bitmanip_zba=0 -set=bitmanip_zbb=0 -set=bitmanip_zbc=0 -set=bitmanip_zbe=0 -set=bitmanip_zbf=0 -set=bitmanip_zbp=0 -set=bitmanip_zbr=0 -set=bitmanip_zbs=0 -set=pic_total_int=1 -set=btb_enable=0 -set=iccm_enable=1 -set=iccm_region=0x0 -set=iccm_offset=0x0 -set=iccm_size=128 -set=dccm_enable=1 -set=dccm_region=0x0 -set=dccm_offset=0x20000 -set=dccm_size=128 
# 
# To use this in a perf script, use 'require $RV_ROOT/configs/config.pl'
# Reference the hash via $config{name}..


%config = (
            'user_ec_rv_icg' => 'user_clock_gate',
            'max_mmode_perf_event' => '516',
            'physical' => '1',
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
                              'reset' => [
                                           '0x23e00000',
                                           '0x00000000',
                                           '0x00000000'
                                         ],
                              'poke_mask' => [
                                               '0x081818c7',
                                               '0xffffffff',
                                               '0x00000000'
                                             ],
                              'mask' => [
                                          '0x081818c7',
                                          '0xffffffff',
                                          '0x00000000'
                                        ]
                            },
                            {
                              'mask' => [
                                          '0x081810c7',
                                          '0xffffffff',
                                          '0x00000000'
                                        ],
                              'poke_mask' => [
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
            'iccm' => {
                        'iccm_reserved' => '0x1000',
                        'iccm_bank_bits' => 2,
                        'iccm_offset' => '0x0',
                        'iccm_size_128' => '',
                        'iccm_index_bits' => 13,
                        'iccm_data_cell' => 'ram_8192x39',
                        'iccm_num_banks_4' => '',
                        'iccm_enable' => 1,
                        'iccm_num_banks' => '4',
                        'iccm_bits' => 17,
                        'iccm_eadr' => '0x0001ffff',
                        'iccm_region' => '0x0',
                        'iccm_bank_index_lo' => 4,
                        'iccm_sadr' => '0x00000000',
                        'iccm_rows' => '8192',
                        'iccm_ecc_width' => '7',
                        'iccm_bank_hi' => 3,
                        'iccm_size' => 128
                      },
            'retstack' => {
                            'ret_stack_size' => '2'
                          },
            'core' => {
                        'bitmanip_zbc' => '0',
                        'lsu_num_nbload_width' => '2',
                        'bitmanip_zbs' => '0',
                        'iccm_only' => 1,
                        'bitmanip_zba' => '0',
                        'no_iccm_no_icache' => 'derived',
                        'iccm_icache' => 'derived',
                        'div_bit' => '4',
                        'fast_interrupt_redirect' => '1',
                        'bitmanip_zbe' => 0,
                        'timer_legal_en' => '1',
                        'bitmanip_zbf' => 0,
                        'icache_only' => 'derived',
                        'lsu2dma' => 0,
                        'lsu_num_nbload' => '4',
                        'div_new' => 1,
                        'bitmanip_zbr' => 0,
                        'bitmanip_zbb' => '0',
                        'bitmanip_zbp' => 0,
                        'lsu_stbuf_depth' => '4',
                        'dma_buf_depth' => '5'
                      },
            'target' => 'typical_pd',
            'regwidth' => '32',
            'reset_vec' => '0x80000000',
            'num_mmode_perf_regs' => '4',
            'testbench' => {
                             'ext_addrwidth' => '32',
                             'RV_TOP' => '`TOP.rvtop_wrapper.rvtop',
                             'clock_period' => '100',
                             'ext_datawidth' => '64',
                             'lderr_rollback' => '1',
                             'CPU_TOP' => '`RV_TOP.veer',
                             'build_axi4' => 1,
                             'SDVT_AHB' => 0,
                             'sterr_rollback' => '0',
                             'build_axi_native' => 1,
                             'TOP' => 'tb_top'
                           },
            'numiregs' => '32',
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
            'csr' => {
                       'cycle' => {
                                    'exists' => 'false'
                                  },
                       'mhartid' => {
                                      'reset' => '0x0',
                                      'exists' => 'true',
                                      'mask' => '0x0',
                                      'poke_mask' => '0xfffffff0'
                                    },
                       'meicidpl' => {
                                       'exists' => 'true',
                                       'mask' => '0xf',
                                       'number' => '0xbcb',
                                       'comment' => 'External interrupt claim id priority level.',
                                       'reset' => '0x0'
                                     },
                       'mhpmevent5' => {
                                         'mask' => '0xffffffff',
                                         'exists' => 'true',
                                         'reset' => '0x0'
                                       },
                       'mfdhs' => {
                                    'reset' => '0x0',
                                    'number' => '0x7cf',
                                    'mask' => '0x00000003',
                                    'comment' => 'Force Debug Halt Status',
                                    'exists' => 'true'
                                  },
                       'dmst' => {
                                   'comment' => 'Memory synch trigger: Flush caches in debug mode.',
                                   'mask' => '0x0',
                                   'number' => '0x7c4',
                                   'exists' => 'true',
                                   'reset' => '0x0',
                                   'debug' => 'true'
                                 },
                       'mcounteren' => {
                                         'exists' => 'false'
                                       },
                       'mie' => {
                                  'reset' => '0x0',
                                  'mask' => '0x70000888',
                                  'exists' => 'true'
                                },
                       'mimpid' => {
                                     'exists' => 'true',
                                     'mask' => '0x0',
                                     'reset' => '0x4'
                                   },
                       'mitbnd0' => {
                                      'exists' => 'true',
                                      'number' => '0x7d3',
                                      'mask' => '0xffffffff',
                                      'reset' => '0xffffffff'
                                    },
                       'mip' => {
                                  'mask' => '0x0',
                                  'poke_mask' => '0x70000888',
                                  'exists' => 'true',
                                  'reset' => '0x0'
                                },
                       'tselect' => {
                                      'mask' => '0x3',
                                      'exists' => 'true',
                                      'reset' => '0x0'
                                    },
                       'mitbnd1' => {
                                      'exists' => 'true',
                                      'mask' => '0xffffffff',
                                      'number' => '0x7d6',
                                      'reset' => '0xffffffff'
                                    },
                       'mitcnt0' => {
                                      'reset' => '0x0',
                                      'exists' => 'true',
                                      'number' => '0x7d2',
                                      'mask' => '0xffffffff'
                                    },
                       'mhpmcounter5h' => {
                                            'exists' => 'true',
                                            'mask' => '0xffffffff',
                                            'reset' => '0x0'
                                          },
                       'mitcnt1' => {
                                      'reset' => '0x0',
                                      'exists' => 'true',
                                      'mask' => '0xffffffff',
                                      'number' => '0x7d5'
                                    },
                       'mfdht' => {
                                    'comment' => 'Force Debug Halt Threshold',
                                    'mask' => '0x0000003f',
                                    'number' => '0x7ce',
                                    'exists' => 'true',
                                    'reset' => '0x0',
                                    'shared' => 'true'
                                  },
                       'mitctl0' => {
                                      'exists' => 'true',
                                      'mask' => '0x00000007',
                                      'number' => '0x7d4',
                                      'reset' => '0x1'
                                    },
                       'mhpmcounter6h' => {
                                            'reset' => '0x0',
                                            'mask' => '0xffffffff',
                                            'exists' => 'true'
                                          },
                       'mhpmevent4' => {
                                         'reset' => '0x0',
                                         'mask' => '0xffffffff',
                                         'exists' => 'true'
                                       },
                       'mitctl1' => {
                                      'exists' => 'true',
                                      'mask' => '0x0000000f',
                                      'number' => '0x7d7',
                                      'reset' => '0x1'
                                    },
                       'mhpmcounter3h' => {
                                            'exists' => 'true',
                                            'mask' => '0xffffffff',
                                            'reset' => '0x0'
                                          },
                       'mscause' => {
                                      'mask' => '0x0000000f',
                                      'number' => '0x7ff',
                                      'exists' => 'true',
                                      'reset' => '0x0'
                                    },
                       'mpmc' => {
                                   'exists' => 'true',
                                   'mask' => '0x2',
                                   'number' => '0x7c6',
                                   'reset' => '0x2'
                                 },
                       'time' => {
                                   'exists' => 'false'
                                 },
                       'instret' => {
                                      'exists' => 'false'
                                    },
                       'mhpmcounter4' => {
                                           'mask' => '0xffffffff',
                                           'exists' => 'true',
                                           'reset' => '0x0'
                                         },
                       'mhpmevent3' => {
                                         'reset' => '0x0',
                                         'exists' => 'true',
                                         'mask' => '0xffffffff'
                                       },
                       'meicurpl' => {
                                       'exists' => 'true',
                                       'number' => '0xbcc',
                                       'mask' => '0xf',
                                       'comment' => 'External interrupt current priority level.',
                                       'reset' => '0x0'
                                     },
                       'mcpc' => {
                                   'reset' => '0x0',
                                   'exists' => 'true',
                                   'comment' => 'Core pause',
                                   'mask' => '0x0',
                                   'number' => '0x7c2'
                                 },
                       'dcsr' => {
                                   'reset' => '0x40000003',
                                   'debug' => 'true',
                                   'mask' => '0x00008c04',
                                   'poke_mask' => '0x00008dcc',
                                   'exists' => 'true'
                                 },
                       'micect' => {
                                     'exists' => 'true',
                                     'mask' => '0xffffffff',
                                     'number' => '0x7f0',
                                     'reset' => '0x0'
                                   },
                       'mstatus' => {
                                      'reset' => '0x1800',
                                      'exists' => 'true',
                                      'mask' => '0x88'
                                    },
                       'mcountinhibit' => {
                                            'mask' => '0x7d',
                                            'poke_mask' => '0x7d',
                                            'exists' => 'true',
                                            'commnet' => 'Performance counter inhibit. One bit per counter.',
                                            'reset' => '0x0'
                                          },
                       'dicad0' => {
                                     'debug' => 'true',
                                     'reset' => '0x0',
                                     'exists' => 'true',
                                     'number' => '0x7c9',
                                     'mask' => '0xffffffff',
                                     'comment' => 'Cache diagnostics.'
                                   },
                       'mvendorid' => {
                                        'exists' => 'true',
                                        'mask' => '0x0',
                                        'reset' => '0x45'
                                      },
                       'meipt' => {
                                    'exists' => 'true',
                                    'mask' => '0xf',
                                    'comment' => 'External interrupt priority threshold.',
                                    'number' => '0xbc9',
                                    'reset' => '0x0'
                                  },
                       'mfdc' => {
                                   'reset' => '0x00070040',
                                   'mask' => '0x00071fff',
                                   'number' => '0x7f9',
                                   'exists' => 'true'
                                 },
                       'dicawics' => {
                                       'exists' => 'true',
                                       'mask' => '0x0130fffc',
                                       'number' => '0x7c8',
                                       'comment' => 'Cache diagnostics.',
                                       'debug' => 'true',
                                       'reset' => '0x0'
                                     },
                       'mcgc' => {
                                   'number' => '0x7f8',
                                   'poke_mask' => '0x000003ff',
                                   'mask' => '0x000003ff',
                                   'exists' => 'true',
                                   'reset' => '0x200'
                                 },
                       'dicago' => {
                                     'reset' => '0x0',
                                     'debug' => 'true',
                                     'mask' => '0x0',
                                     'comment' => 'Cache diagnostics.',
                                     'number' => '0x7cb',
                                     'exists' => 'true'
                                   },
                       'misa' => {
                                   'reset' => '0x40001104',
                                   'mask' => '0x0',
                                   'exists' => 'true'
                                 },
                       'mhpmcounter3' => {
                                           'reset' => '0x0',
                                           'exists' => 'true',
                                           'mask' => '0xffffffff'
                                         },
                       'mrac' => {
                                   'shared' => 'true',
                                   'reset' => '0x0',
                                   'exists' => 'true',
                                   'mask' => '0xffffffff',
                                   'number' => '0x7c0',
                                   'comment' => 'Memory region io and cache control.'
                                 },
                       'dicad1' => {
                                     'reset' => '0x0',
                                     'debug' => 'true',
                                     'mask' => '0x3',
                                     'number' => '0x7ca',
                                     'comment' => 'Cache diagnostics.',
                                     'exists' => 'true'
                                   },
                       'mhpmcounter4h' => {
                                            'exists' => 'true',
                                            'mask' => '0xffffffff',
                                            'reset' => '0x0'
                                          },
                       'marchid' => {
                                      'reset' => '0x00000010',
                                      'exists' => 'true',
                                      'mask' => '0x0'
                                    },
                       'miccmect' => {
                                       'reset' => '0x0',
                                       'exists' => 'true',
                                       'number' => '0x7f1',
                                       'mask' => '0xffffffff'
                                     },
                       'mdccmect' => {
                                       'exists' => 'true',
                                       'mask' => '0xffffffff',
                                       'number' => '0x7f2',
                                       'reset' => '0x0'
                                     },
                       'mhpmcounter5' => {
                                           'reset' => '0x0',
                                           'exists' => 'true',
                                           'mask' => '0xffffffff'
                                         },
                       'mhpmevent6' => {
                                         'mask' => '0xffffffff',
                                         'exists' => 'true',
                                         'reset' => '0x0'
                                       },
                       'mhpmcounter6' => {
                                           'reset' => '0x0',
                                           'exists' => 'true',
                                           'mask' => '0xffffffff'
                                         }
                     },
            'xlen' => 32,
            'even_odd_trigger_chains' => 'true',
            'protection' => {
                              'data_access_enable7' => '0x0',
                              'inst_access_mask6' => '0xffffffff',
                              'data_access_enable1' => '0x0',
                              'inst_access_addr4' => '0x00000000',
                              'inst_access_mask5' => '0xffffffff',
                              'inst_access_enable5' => '0x0',
                              'pmp_entries' => '16',
                              'inst_access_addr0' => '0x00000000',
                              'data_access_enable4' => '0x0',
                              'data_access_mask2' => '0xffffffff',
                              'inst_access_addr7' => '0x00000000',
                              'data_access_mask1' => '0xffffffff',
                              'data_access_mask3' => '0xffffffff',
                              'data_access_enable2' => '0x0',
                              'data_access_addr4' => '0x00000000',
                              'data_access_mask5' => '0xffffffff',
                              'inst_access_enable1' => '0x0',
                              'data_access_mask6' => '0xffffffff',
                              'inst_access_enable7' => '0x0',
                              'data_access_addr7' => '0x00000000',
                              'inst_access_mask2' => '0xffffffff',
                              'inst_access_mask3' => '0xffffffff',
                              'inst_access_enable2' => '0x0',
                              'inst_access_mask1' => '0xffffffff',
                              'data_access_enable5' => '0x0',
                              'inst_access_enable4' => '0x0',
                              'data_access_addr0' => '0x00000000',
                              'inst_access_mask0' => '0xffffffff',
                              'data_access_enable6' => '0x0',
                              'data_access_enable0' => '0x0',
                              'data_access_enable3' => '0x0',
                              'inst_access_mask7' => '0xffffffff',
                              'data_access_addr2' => '0x00000000',
                              'data_access_addr1' => '0x00000000',
                              'data_access_addr3' => '0x00000000',
                              'inst_access_addr6' => '0x00000000',
                              'inst_access_mask4' => '0xffffffff',
                              'inst_access_addr5' => '0x00000000',
                              'data_access_mask7' => '0xffffffff',
                              'inst_access_addr2' => '0x00000000',
                              'inst_access_enable6' => '0x0',
                              'inst_access_enable3' => '0x0',
                              'inst_access_enable0' => '0x0',
                              'inst_access_addr3' => '0x00000000',
                              'inst_access_addr1' => '0x00000000',
                              'data_access_mask0' => '0xffffffff',
                              'data_access_mask4' => '0xffffffff',
                              'data_access_addr5' => '0x00000000',
                              'data_access_addr6' => '0x00000000'
                            },
            'config_key' => '32\'hdeadbeef',
            'icache' => {
                          'icache_fdata_width' => 71,
                          'icache_tag_lo' => 13,
                          'icache_size' => 16,
                          'icache_tag_num_bypass' => '2',
                          'icache_ln_sz' => 64,
                          'icache_num_lines_way' => '128',
                          'icache_tag_index_lo' => '6',
                          'icache_num_lines_bank' => '64',
                          'icache_2banks' => '1',
                          'icache_bank_bits' => 1,
                          'icache_beat_bits' => 3,
                          'icache_data_depth' => '512',
                          'icache_data_cell' => 'ram_512x71',
                          'icache_num_ways' => 2,
                          'icache_waypack' => '1',
                          'icache_num_bypass_width' => 2,
                          'icache_index_hi' => 12,
                          'icache_tag_cell' => 'ram_128x25',
                          'icache_num_bypass' => '2',
                          'icache_tag_num_bypass_width' => 2,
                          'icache_bank_hi' => 3,
                          'icache_bank_width' => 8,
                          'icache_data_width' => 64,
                          'icache_num_lines' => 256,
                          'icache_beat_addr_hi' => 5,
                          'icache_bank_lo' => 3,
                          'icache_tag_depth' => 128,
                          'icache_bypass_enable' => '1',
                          'icache_status_bits' => 1,
                          'icache_scnd_last' => 6,
                          'icache_data_index_lo' => 4,
                          'icache_num_beats' => 8,
                          'icache_ecc' => '1',
                          'icache_tag_bypass_enable' => '1',
                          'icache_banks_way' => 2
                        },
            'dccm' => {
                        'dccm_fdata_width' => 39,
                        'dccm_width_bits' => 2,
                        'lsu_sb_bits' => 17,
                        'dccm_reserved' => '0x1400',
                        'dccm_data_cell' => 'ram_16384x39',
                        'dccm_offset' => '0x20000',
                        'dccm_bits' => 17,
                        'dccm_enable' => '1',
                        'dccm_size' => 128,
                        'dccm_ecc_width' => 7,
                        'dccm_region' => '0x0',
                        'dccm_sadr' => '0x20000',
                        'dccm_eadr' => '0x3ffff',
                        'dccm_data_width' => 32,
                        'dccm_bank_bits' => 1,
                        'dccm_index_bits' => 14,
                        'dccm_size_128' => '',
                        'dccm_byte_width' => '4',
                        'dccm_num_banks' => '2',
                        'dccm_num_banks_2' => '',
                        'dccm_rows' => '16384'
                      },
            'bht' => {
                       'bht_array_depth' => 64,
                       'bht_ghr_hash_1' => 1,
                       'bht_hash_string' => '{ghr[5:4], hashin[5:2]^ghr[4-1:0]} // cf1',
                       'bht_size' => 128,
                       'bht_ghr_size' => 6,
                       'bht_addr_hi' => 7,
                       'bht_addr_lo' => '2',
                       'bht_ghr_range' => '5:0'
                     },
            'nmi_vec' => '0x11110000',
            'bus' => {
                       'lsu_bus_id' => '1',
                       'ifu_bus_id' => '1',
                       'dma_bus_tag' => '1',
                       'ifu_bus_prty' => '2',
                       'sb_bus_id' => '1',
                       'lsu_bus_prty' => '2',
                       'sb_bus_tag' => '1',
                       'bus_prty_default' => '3',
                       'sb_bus_prty' => '2',
                       'dma_bus_prty' => '2',
                       'dma_bus_id' => '1',
                       'ifu_bus_tag' => '3',
                       'lsu_bus_tag' => 3
                     },
            'tec_rv_icg' => 'clockhdr',
            'memmap' => {
                          'unused_region5' => '0x40000000',
                          'unused_region1' => '0x90000000',
                          'unused_region6' => '0x30000000',
                          'unused_region2' => '0x70000000',
                          'debug_sb_mem' => '0xb0580000',
                          'consoleio' => '0xe0580000',
                          'unused_region7' => '0x20000000',
                          'unused_region8' => '0x10000000',
                          'external_data_1' => '0xc0000000',
                          'unused_region0' => '0xa0000000',
                          'unused_region3' => '0x60000000',
                          'unused_region4' => '0x50000000',
                          'serialio' => '0xe0580000',
                          'external_data' => '0xd0580000'
                        },
            'harts' => 1,
            'pic' => {
                       'pic_total_int' => 1,
                       'pic_meipl_offset' => '0x0000',
                       'pic_meip_offset' => '0x1000',
                       'pic_meip_mask' => '0x0',
                       'pic_meigwctrl_offset' => '0x4000',
                       'pic_meipl_mask' => '0xf',
                       'pic_mpiccfg_offset' => '0x3000',
                       'pic_total_int_plus1' => 2,
                       'pic_int_words' => 0,
                       'pic_meigwclr_mask' => '0x0',
                       'pic_meigwctrl_count' => 1,
                       'pic_meigwclr_count' => 1,
                       'pic_meip_count' => 0,
                       'pic_bits' => 15,
                       'pic_meipl_count' => 1,
                       'pic_meipt_offset' => '0x3004',
                       'pic_mpiccfg_count' => 1,
                       'pic_meipt_mask' => '0x0',
                       'pic_meie_count' => 1,
                       'pic_size' => 32,
                       'pic_mpiccfg_mask' => '0x1',
                       'pic_meie_offset' => '0x2000',
                       'pic_offset' => '0xc0000',
                       'pic_meigwctrl_mask' => '0x3',
                       'pic_meie_mask' => '0x1',
                       'pic_base_addr' => '0xf00c0000',
                       'pic_meigwclr_offset' => '0x5000',
                       'pic_meipt_count' => 1,
                       'pic_region' => '0xf'
                     },
            'btb' => {
                       'btb_btag_size' => 9,
                       'btb_index3_hi' => 13,
                       'btb_index1_hi' => 5,
                       'btb_btag_fold' => 1,
                       'btb_array_depth' => 16,
                       'btb_toffset_size' => '12',
                       'btb_size' => 32,
                       'btb_index2_lo' => 6,
                       'btb_addr_lo' => '2',
                       'btb_fold2_index_hash' => 0,
                       'btb_index2_hi' => 9,
                       'btb_addr_hi' => 5,
                       'btb_index3_lo' => 10,
                       'btb_index1_lo' => '2'
                     }
          );
1;
