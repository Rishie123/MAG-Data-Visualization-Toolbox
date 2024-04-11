Info	04/10/24	15:21:22.957	GSEOS	0	1	********************************************************************************
Info	04/10/24	15:21:22.959	GSEOS	0	1	GSEOS 8.1.1491
Info	04/10/24	15:21:22.960	GSEOS	0	1	IMAP
Info	04/10/24	15:21:22.961	GSEOS	0	1	Platform: Windows-10-10.0.22621
Info	04/10/24	15:21:22.961	GSEOS	0	1	Wed Apr 10 15:21:22 2024
Info	04/10/24	15:21:22.961	GSEOS	0	1	********************************************************************************
Error	04/10/24	15:21:23.586	Net	0	1	Net server error: No valid port configured, server "NET_OASIS_SCE_IN_ANALOG" disabled.
Error	04/10/24	15:21:23.586	Net	0	1	Net server error: No valid port configured, server "NET_OASIS_SCE_IN_STATUS" disabled.
Info	04/10/24	15:21:23.588	Net	0	1	Server connection: pytest_recv_tlm has been started.
Info	04/10/24	15:21:23.588	Net	0	1	Server connection: pytest_send_tc has been started.
Info	04/10/24	15:21:23.588	Net	0	1	Server connection: NET_OASIS_SEND_CMD has been started.
Info	04/10/24	15:21:23.588	Net	0	1	Server connection: NET_OASIS_RECV_INST_TLM has been started.
Info	04/10/24	15:21:23.588	Net	0	1	Server connection: NET_OASIS_CMD_DECODER_STATUS has been started.
Info	04/10/24	15:21:23.588	Net	0	1	Server connection: NET_OASIS_SEND_SCE_CMD has been started.
Info	04/10/24	15:21:23.614	Binary Writer	0	1	Binary Writer: "CCSDS_FRAG_TLM" started.
Info	04/10/24	15:21:24.401	Version	0	1	
Info	04/10/24	15:21:24.401	Version	0	1	Version Control Information
Info	04/10/24	15:21:24.401	Version	0	1	----------------------------------------------------------------------
Info	04/10/24	15:21:24.401	Version	0	1	GSEOS:         8.1.1491
Info	04/10/24	15:21:24.401	Version	0	1	Python:        3.7.7 (default, Jun 19 2020, 21:06:32) [MSC v.1900 64 bit (AMD64)]
Info	04/10/24	15:21:24.401	Version	0	1	ExcelLoad:     4.2.042
Info	04/10/24	15:21:24.401	Version	0	1	IMAP - MAG:
Info	04/10/24	15:21:24.401	Version	0	1	
Info	04/10/24	15:21:24.401	Version	0	1	Spreadsheet Version Information
Info	04/10/24	15:21:24.401	Version	0	1	----------------------------------------------------------------------
Info	04/10/24	15:21:24.401	Version	0	1	Instruments\MAG_Common\CMD_MAG.xls (Release: 2023-09-01 Rev: None) converted: Wed Mar 27 15:04:26 2024
Info	04/10/24	15:21:24.401	Version	0	1	Instruments\MAG_Common\TLM_MAG.xls (Release: 2023-09-01 Rev: 1.0) converted: Wed Mar 27 15:16:50 2024
Info	04/10/24	15:21:24.401	Version	0	1	Instruments\MAG_Common\TLM_MAG_SCI.xls (Release: 2023-09-01 Rev: 1.0) converted: Mon Dec 11 14:54:19 2023
Info	04/10/24	15:21:24.401	Version	0	1	Instruments\MAG_Common\TLM_MAG_decoders.xls (Release: 0000-00-00 Rev: 0.0) converted: Fri Feb  9 14:20:08 2024
Info	04/10/24	15:21:24.401	Version	0	1	Instruments\MAG_Common\TLM_MAG_soloScience.xls (Release: 0000-00-00 Rev: 0.0) converted: Mon Dec 11 14:54:45 2023
Info	04/10/24	15:21:24.401	Version	0	1	----------------------------------------------------------------------
Info	04/10/24	15:21:24.401	Version	0	1	
Info	04/10/24	15:21:24.558	IMAP_Bios	0	1	Loading IMAP SCE interface.
Info	04/10/24	15:21:24.559	Message	0	1	Setting Message Filter: Error reading from pipeOut:*, ERROR, OKBios, 0.
Info	04/10/24	15:21:24.727	OKBios	0	1	Initializing device: XEM1
Info	04/10/24	15:21:24.729	OKBios	0	1	Entering device service thread for device: XEM1.
Error	04/10/24	15:21:24.766	OKBios	0	1	Error initializing device: XEM1: No Opal Kelly FrontPanel devices found.
Error	04/10/24	15:21:24.767	IMAP_Bios	0	1	Error importing module OKBios: Error initializing device: XEM1: No Opal Kelly FrontPanel devices found..
Info	04/10/24	15:21:24.767	Message	0	1	Removing Message Filter: Error reading from pipeOut:*, ERROR, OKBios, 0.
Info	04/10/24	15:21:24.778	OKBios	0	1	Device service thread for device: XEM1 terminated.
Warn	04/10/24	15:21:24.848	User	0	1	config: Instrument Sys Path not configured
Info	04/10/24	15:21:24.848	User	0	1	config: Initializing Command Logger
Info	04/10/24	15:21:24.976	User	0	1	config:CommandLogger - Ignoring commands matching regex: 'xxx'
Warn	04/10/24	15:21:24.977	User	0	1	config: Telemetry Monitor not configured
Warn	04/10/24	15:21:24.977	User	0	1	config: Memory Dump Monitor not configured
Warn	04/10/24	15:21:24.977	User	0	1	config: Alarm Monitor not configured
Warn	04/10/24	15:21:24.977	User	0	1	config: UDP Exploder not configured
Info	04/10/24	15:21:24.977	User	0	1	config: Initializing CCSDS Dispatcher
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x431 -> MAG_EHS_ERRDATA
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x401 -> MAG_EHS_BSW
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x425 -> MAG_ELS_ITF
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x40e -> MAG_MEM_MRAMTSEGREP
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x433 -> MAG_TCC_FEEFAIL
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x435 -> MAG_TCC_PARAMFAIL
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x436 -> MAG_TCC_FILEFAIL
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x415 -> MAG_HSK_SID20
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x3e3 -> MAG_PROG_NOOP
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x406 -> MAG_PROG_BTSUCC
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x405 -> MAG_PROG_BTSUCC
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x400 -> MAG_PROG_MTRAN
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x422 -> MAG_TCA_SUCC
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x423 -> MAG_TCC_SUCC
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x404 -> MAG_HSK_SID1
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x41f -> MAG_HSK_SID2
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x427 -> MAG_HSK_PW
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x428 -> MAG_HSK_STATUS
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x41b -> MAG_HSK_PROCSTAT
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x43a -> MAG_HSK_SCI
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x43b -> MAG_HSK_SCI
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x41d -> MAG_HSK_SID15
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x424 -> MAG_HSK_SID12
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x41e -> MAG_HSK_SID16
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x3e9 -> MAG_SCI_IALIRT
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x3fc -> MAG_SCI_IALIRT
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x40c -> MAG_SCI_1920
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x41c -> MAG_SCI_NORM
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x42c -> MAG_SCI_BURST
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x409 -> MAG_MEM_CHCKREP
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x3fa -> MAG_MEM_DMP
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x40d -> MAG_HSK_HKADCPRMLIM
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x3e8 -> MAG_HSK_AUTONOMY
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x426 -> MAG_TCA_INVCCSDS
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x429 -> MAG_TCC_FAIL
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x42a -> MAG_TCC_FAILMEM
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x42b -> MAG_EHS_SWTRAP
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x42d -> MAG_TCC_SPIERR
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x42f -> MAG_EHS_AUTONOMY
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x430 -> MAG_EHS_GENEVNT
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x42e -> MAG_EHS_HKADC
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x402 -> MAG_EHS_SWPCKDROP
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x40a -> MAG_EHS_CRSHREP
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x439 -> MAG_ELS_CONFLD
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x438 -> MAG_EHS_FEE
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x437 -> MAG_EHS_BUFF
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x432 -> MAG_EHS_SEMAPH
Info	04/10/24	15:21:25.020	User	0	1	config:ccsds_dispatch - APID 0x3fe -> MAG_EHS_OSERR
Info	04/10/24	15:21:25.022	User	0	1	config:ccsds_dispatch - APID 0x434 -> MAG_TCC_OSFAIL
Warn	04/10/24	15:21:25.022	User	0	1	config: Telemetry Watchdog not configured
Warn	04/10/24	15:21:25.022	User	0	1	config: Binary Log not configured
Info	04/10/24	15:21:25.022	User	0	1	config: Initializing CSV Exports
Info	04/10/24	15:21:25.058	User	0	1	config:csvlog - export_sidone
Info	04/10/24	15:21:25.058	User	0	1	config:csvlog - export_conf
Info	04/10/24	15:21:25.062	User	0	1	config:csvlog - export_sidtwo
Info	04/10/24	15:21:25.062	User	0	1	config:csvlog - export_data
Info	04/10/24	15:21:25.063	User	0	1	config:csvlog - export_pwr
Info	04/10/24	15:21:25.063	User	0	1	config:csvlog - export_stat
Info	04/10/24	15:21:25.063	User	0	1	config:csvlog - export_proc
Info	04/10/24	15:21:25.063	User	0	1	config:csvlog - export_mem
Info	04/10/24	15:21:25.065	User	0	1	config:csvlog - export_hkadc
Info	04/10/24	15:21:25.065	User	0	1	config:csvlog - export_ialirt
Warn	04/10/24	15:21:25.075	User	0	1	config: Test Core not configured
Warn	04/10/24	15:21:25.075	User	0	1	config: Recorder not configured
Warn	04/10/24	15:21:25.075	User	0	1	config: RS232 BIOS not configured
Info	04/10/24	15:21:34.221	Sequencer	0	1	Sequencer 'SCE_IN_STATUS Simulator' started.
Info	04/10/24	15:21:35.980	Sequencer	0	1	Sequencer 'Check Time & Status Customization File Existence' started.
Info	04/10/24	15:21:36.792	Net	0	1	Client connection: tsim established.
Error	04/10/24	15:28:15.755	Screen	0	1	Error computing formula EPOCH_Second: [Errno 22] Invalid argument
Error	04/10/24	15:28:15.755	Screen	0	1	Error computing formula EPOCH_Minute: [Errno 22] Invalid argument
Error	04/10/24	15:28:15.755	Screen	0	1	Error computing formula EPOCH_Hour: [Errno 22] Invalid argument
Error	04/10/24	15:28:15.755	Screen	0	1	Error computing formula EPOCH_Day: [Errno 22] Invalid argument
Error	04/10/24	15:28:15.755	Screen	0	1	Error computing formula EPOCH_Month: [Errno 22] Invalid argument
Error	04/10/24	15:28:15.755	Screen	0	1	Error computing formula EPOCH_Year: [Errno 22] Invalid argument
Info	04/10/24	15:30:25.737	Net	0	1	Client connection: tsim has been closed by remote end.
Info	04/10/24	15:30:27.028	Net	0	1	Client connection: tsim established.
Info	04/10/24	15:30:27.229	Net	0	1	Client connection: tsim has been closed by remote end.
