# File: /live/custom/antiX/0.sh
# antiX Specific /init code

LIST_MODULES=true
CHECK_BOOTCODES=true

MENUS_LIST=wltompfdsv

DO_DEB=true
DO_FSCK=true
DO_XTRA=true
DO_GFX=true

FANCY_PROMPT="prompt-fancy"
AUTO_LOGIN_PROG="autologin"
AUTO_LOGIN_TERMS="2-4"

live_param_filter() {
    local param val disable
    for param; do
        val=${param#*=}

        case $param in
        disable=*)                       disable=$val ;;
        lean)                           CMD_LEAN=true ;;
        mean)                           CMD_MEAN=true ;;
        Xtralean)                  CMD_XTRA_LEAN=true ;;
        nodbus)                      CMD_NO_DBUS=true ;;

        # Our Live params
        hwclock=utc|hwclock=local|xorg|xorg=*|noearlyvid|earlyvid) ;;
        amnt|amnt=*|automount|automount=*|confont=*|conkeys=*);;
        mount=*|noautomount) ;;
        desktop=*|dpi=*|fstab=*|hostname=*|kbd=*|kbopt=*|kbvar=*);;
        lang=*|mirror=*|noloadkeys|noprompt);;
        nosplash|password|password=*|prompt|pw|pw=*|tz=*|ubp=*|ushow=*);;
        uverb=*|xres=*|noxorg);;
        desktheme=*) ;;
        nosavestate|savestate|dbsavestate) ;;
        norepo|norepo=*|nostore) ;;
        deskdelay=*) ;;
        udpi=*|sdpi=*) ;;
        fontsize=*) ;;
        skylakeflicker)  ;;
        i915powersave) ;;
        wicd|nowicd) ;;
        nomicrocode);;
        live_swap=off)  ;;
        live_swap=force)  ;;
        live_swap=all-off)  ;;
        mk_swap_file=*)     ;;

        # Most kernel codes from version 4.19 (plus additions)
        3c574_cs.*=*|3c589_cs.*=*|3c59x.*=*|3w-9xxx.*=*|3w-sas.*=*|8139cp.*=*|8139too.*=*|8250.*=*|8390.*=*);;
        842_compress.*=*|842_decompress.*=*|BusLogic.*=*|aacraid.*=*|abituguru.*=*|abituguru3.*=*|acenic.*=*);;
        acer-wmi.*=*|acerhdf.*=*|acpi-cpufreq.*=*|acpi.*=*|acpi.debug_layer=*|acpi.debug_level=*|acpi=*);;
        acpi_apic_instance=*|acpi_backlight=*|acpi_cpufreq.*=*|acpi_enforce_resources=*|acpi_force_32bit_fadt_addr);;
        acpi_force_table_verification|acpi_irq_balance|acpi_irq_isa=*|acpi_irq_nobalance|acpi_irq_pci=*);;
        acpi_mask_gpe=*|acpi_no_auto_serialize|acpi_no_memhotplug|acpi_no_static_ssdt|acpi_os_name=*|acpi_osi=*);;
        acpi_pm_good|acpi_power_meter.*=*|acpi_rev_override|acpi_rsdp=*|acpi_sci=*|acpi_skip_timer_override);;
        acpi_sleep=*|acpi_use_timer_override|acpica_no_return_repair|acpiphp.*=*|acquirewdt.*=*|ad7877.*=*);;
        add_efi_memmap|adm1021.*=*|adm1026.*=*|adm8211.*=*|adv7170.*=*|adv7175.*=*|adv7511.*=*|adv7604.*=*);;
        adv7842.*=*|advantechwdt.*=*|aer_inject.*=*|agp=*|aha152x_cs.*=*|ahci.*=*|aic79xx.*=*|aic7xxx.*=*|aic94xx.*=*);;
        aiptek.*=*|airo.*=*|ali-ircc.*=*|align_va_addr=*|alignment=*|alim1535_wdt.*=*|alim7101_wdt.*=*|alloc_snapshot);;
        altera-ci.*=*|altera-stapl.*=*|altera_tse.*=*|am53c974.*=*|ambassador.*=*|amc6821.*=*|amd-xgbe.*=*);;
        amd64-agp.*=*|amd64_edac_mod.*=*|amd76xrom.*=*|amd8111e.*=*|amd_iommu=*|amd_iommu_dump=*|amd_iommu_intr=*);;
        amdgpu.*=*|amdkfd.*=*|amijoy.map=*|analog.*=*|analog.map=*|ansi_cprng.*=*|aoe.*=*|apc=*|apic=*|apic_extnmi=*);;
        apm=*|apparmor.*=*|apparmor=*|apple_bl.*=*|appletouch.*=*|applicom.*=*|arc-rimi.*=*|arcfb.*=*|arcmsr.*=*);;
        arcnet.*=*|arcrimi=*|arkfb.*=*|asb100.*=*|ast.*=*|asus-laptop.*=*|asus-nb-wmi.*=*|asus_atk0110.*=*|at24.*=*);;
        at76c50x-usb.*=*|ata_generic.*=*|ata_piix.*=*|ataflop=*|atarimouse=*|atbm8830.*=*|ath10k_core.*=*);;
        ath10k_pci.*=*|ath5k.*=*|ath6kl_core.*=*|ath9k.*=*|ath9k_htc.*=*|ati_remote.*=*|ati_remote2.*=*|atkbd.extra=*);;
        atkbd.reset=*|atkbd.scroll=*|atkbd.set=*|atkbd.softraw=*|atkbd.softrepeat=*|atl1.*=*|atl1e.*=*|atl2.*=*);;
        atlantic.*=*|atmel.*=*|atp.*=*|aty128fb.*=*|atyfb.*=*|au0828.*=*|au8522_common.*=*|au8522_decoder.*=*);;
        au8522_dig.*=*|audit=*|audit_backlog_limit=*|auth_rpcgss.*=*|autoconf=*|avma1_cs.*=*|avmfritz.*=*|b1dma.*=*);;
        b2c2-flexcop-pci.*=*|b2c2-flexcop-usb.*=*|b2c2-flexcop.*=*|b43.*=*|b43legacy.*=*|b44.*=*|bas_gigaset.*=*);;
        battery.*=*|bau=*|baycom_epp=*|baycom_par.*=*|baycom_par=*|baycom_ser_fdx.*=*|baycom_ser_fdx=*);;
        baycom_ser_hdx.*=*|baycom_ser_hdx=*|bcm3510.*=*|bcm5974.*=*|be2iscsi.*=*|be2net.*=*|bert_disable|bfa.*=*);;
        binder_linux.*=*|blk_cgroup.*=*|blkdevparts=*|block.*=*|block2mtd.*=*|blowfish-x86_64.*=*|bluetooth.*=*);;
        bna.*=*|bnep.*=*|bnx2.*=*|bnx2fc.*=*|bnx2i.*=*|bnx2x.*=*|bochs-drm.*=*|bonding.*=*|boot_delay=*|bootmem_debug);;
        bq27xxx_battery.*=*|bq27xxx_battery_hdq.*=*|brcmfmac.*=*|brd.*=*|bt819.*=*|bt856.*=*|bt866.*=*|bt878.*=*);;
        bttv.*=*|bttv.card=*|bttv.pll=*|bttv.radio=*|bttv.tuner=*|btusb.*=*|budget-av.*=*|budget-ci.*=*);;
        budget-core.*=*|budget-patch.*=*|budget.*=*|bulk_remove=*|button.*=*|c101=*|c4.*=*|ca_keys=*|cachefiles.*=*);;
        cachesize=*|cadence_wdt.*=*|cafe_ccic.*=*|cafe_nand.*=*|caif_serial.*=*|camellia-x86_64.*=*|can-dev.*=*);;
        can-gw.*=*|can.*=*|capi.*=*|capidrv.*=*|carl9170.*=*|carrier_timeout=*|cassini.*=*|cc770.*=*|cc770_isa.*=*);;
        cca=*|ccp-crypto.*=*|ccp.*=*|ccw_timeout_log|cdc_ncm.*=*|cdrom.*=*|cec.*=*|cfag12864b.*=*|cfg80211.*=*);;
        cfspi_slave.*=*|cgroup.memory=*|cgroup_disable=*|cgroup_no_v1=*|ch.*=*|ch7006.*=*|checkreqprot|cifs.*=*);;
        cio_ignore=*|cirrus.*=*|cirrusfb.*=*|ck804xrom.*=*|clearcpuid=*|clk_ignore_unused|clock=*);;
        clocksource.arm_arch_timer.evtstrm=*|clocksource=*|cm109.*=*|cma=*|cmo_free_hint=*|cobalt.*=*|coherent_pool=*);;
        com20020-pci.*=*|com20020=*|com20020_cs.*=*|com90io.*=*|com90io=*|com90xx.*=*|com90xx=*|comedi.*=*);;
        comedi_test.*=*|compal-laptop.*=*|condev=*|conmode=*|console=*|console_msg_format=*|consoleblank=*);;
        coredump_filter=*|coresight_cpu_debug.enable|coretemp.*=*|cpcihp_generic.*=*|cpcihp_generic=*);;
        cpcihp_zt5550.*=*|cpia2.*=*|cpu0_hotplug|cpu5wdt.*=*|cpu_init_udelay=*|cpufreq.*=*|cpufreq.off=*|cpuidle.*=*);;
        cpuidle.governor=*|cpuidle.off=*|crash_kexec_post_notifiers|crashkernel=*|cryptd.*=*|cryptomgr.*=*);;
        cryptomgr.notests|cs5345.*=*|cs53l32a.*=*|cs89x0_dma=*|cs89x0_media=*|cw1200_core.*=*|cx18-alsa.*=*|cx18.*=*);;
        cx22700.*=*|cx22702.*=*|cx231xx-alsa.*=*|cx231xx-dvb.*=*|cx231xx.*=*|cx2341x.*=*|cx23885.*=*|cx24110.*=*);;
        cx24113.*=*|cx24116.*=*|cx24123.*=*|cx25821-alsa.*=*|cx25821.*=*|cx25840.*=*|cx88-alsa.*=*|cx88-blackbird.*=*);;
        cx88-dvb.*=*|cx8800.*=*|cx8802.*=*|cx88xx.*=*|cxd2099.*=*|cxgb.*=*|cxgb3.*=*|cxgb3i.*=*|cxgb4.*=*|cxgb4i.*=*);;
        cxgb4vf.*=*|cyber2000fb.*=*|cypress_m8.*=*|dasd=*|db9.*=*|db9.dev2=*|db9.dev3=*|db9.dev=*|dc395x.*=*|dccp.*=*);;
        ddbridge.*=*|ddebug_query=*|de2104x.*=*|de4x5.*=*|debug|debug_boot_weak_hash|debug_guardpage_minorder=*);;
        debug_locks_verbose=*|debug_objects|debug_pagealloc=*|debugpat|decnet.*=*|decnet.addr=*|default_hugepagesz=*);;
        deferred_probe_timeout=*|dell-laptop.*=*|dell-rbtn.*=*|dell-smm-hwmon.*=*|dell_laptop.*=*|dell_rbu.*=*);;
        des3_ede-x86_64.*=*|dhash_entries=*|dib0070.*=*|dib0090.*=*|dib3000mb.*=*|dib3000mc.*=*|dib7000m.*=*);;
        dib7000p.*=*|dib8000.*=*|dibx000_common.*=*|dis_ucode_ldr|disable=*|disable_1tb_segments|disable_cpu_apicid=*);;
        disable_ddw|disable_ipv6=*|disable_mtrr_cleanup|disable_mtrr_trim|disable_radix|disable_timer_pin_1);;
        diskonchip.*=*|diva_mnt.*=*|divas.*=*|dl2k.*=*|dm-bufio.*=*|dm-cache.*=*|dm-mirror.*=*|dm-mod.*=*|dm-raid.*=*);;
        dm-snapshot.*=*|dm-thin-pool.*=*|dm-verity.*=*|dm1105.*=*|dm_mod.*=*|dma_debug=*|dma_debug_driver=*);;
        dma_debug_entries=*|dme1737.*=*|dmfe.*=*|dns_resolver.*=*|docg3.*=*|docg4.*=*|drbd.*=*|driver_async_probe=*);;
        drm.*=*|drm.edid_firmware=*|drm_kms_helper.*=*|drxk.*=*|ds1621.*=*|ds2482.*=*|ds2760_battery.*=*|ds3000.*=*);;
        dsbr100.*=*|dscc4.*=*|dscc4.setup=*|dst.*=*|dst_ca.*=*|dt_cpu_ftrs=*|dummy-irq.*=*|dummy.*=*|dummy_stm.*=*);;
        dump_apple_properties|dvb-as102.*=*|dvb-bt8xx.*=*|dvb-core.*=*|dvb-pll.*=*|dvb-ttpci.*=*|dvb-ttusb-budget.*=*);;
        dvb-usb-a800.*=*|dvb-usb-af9005-remote.*=*|dvb-usb-af9005.*=*|dvb-usb-af9015.*=*|dvb-usb-af9035.*=*);;
        dvb-usb-anysee.*=*|dvb-usb-au6610.*=*|dvb-usb-az6007.*=*|dvb-usb-az6027.*=*|dvb-usb-ce6230.*=*);;
        dvb-usb-cinergyT2.*=*|dvb-usb-cxusb.*=*|dvb-usb-dib0700.*=*|dvb-usb-dibusb-common.*=*|dvb-usb-dibusb-mb.*=*);;
        dvb-usb-dibusb-mc.*=*|dvb-usb-digitv.*=*|dvb-usb-dtt200u.*=*|dvb-usb-dtv5100.*=*|dvb-usb-dvbsky.*=*);;
        dvb-usb-dw2102.*=*|dvb-usb-ec168.*=*|dvb-usb-friio.*=*|dvb-usb-gl861.*=*|dvb-usb-gp8psk.*=*);;
        dvb-usb-lmedm04.*=*|dvb-usb-m920x.*=*|dvb-usb-mxl111sf.*=*|dvb-usb-nova-t-usb2.*=*|dvb-usb-opera.*=*);;
        dvb-usb-pctv452e.*=*|dvb-usb-rtl28xxu.*=*|dvb-usb-technisat-usb2.*=*|dvb-usb-ttusb2.*=*|dvb-usb-umt-010.*=*);;
        dvb-usb-vp702x.*=*|dvb-usb-vp7045.*=*|dvb-usb.*=*|dvb_usb_v2.*=*|dw_wdt.*=*|dynamic_debug.*=*|dyndbg|dyndbg=*);;
        e100.*=*|e1000.*=*|e1000e.*=*|e752x_edac.*=*|early_ioremap_debug|earlycon=*|earlyprintk=*|earth-pt1.*=*);;
        earth-pt3.*=*|eata.*=*|ec_bhf.*=*|ecryptfs.*=*|edac_core.*=*|edac_report=*|edd=*|eeepc-laptop.*=*);;
        eeepc-wmi.*=*|eeti_ts.*=*|efi-pstore.*=*|efi=*|efi_fake_mem=*|efi_no_storage_paranoia|efi_pstore.*=*);;
        efivar_ssdt=*|ehci-hcd.*=*|ehci_hcd.*=*|eisa_irq_edge=*|ekgdboc=*|elanfreq=*|elevator=*|elfcorehdr=*);;
        elsa_cs.*=*|em28xx-alsa.*=*|em28xx-dvb.*=*|em28xx-rc.*=*|em28xx-v4l.*=*|em28xx.*=*|emc2103.*=*|ena.*=*);;
        enable_mtrr_cleanup|enable_timer_pin_1|enc28j60.*=*|encx24j600.*=*|ene_ir.*=*|enforcing|epat.*=*|epic100.*=*);;
        erst_disable|esas2r.*=*|esp_scsi.*=*|ether=*|ethoc.*=*|eurotechwdt.*=*|evm=*|f71805f.*=*|f71808e_wdt.*=*);;
        f71882fg.*=*|fail_make_request=*|fail_page_alloc=*|failslab=*|fakelb.*=*|farsync.*=*|fb.*=*|fb_hx8340bn.*=*);;
        fb_ili9325.*=*|fb_pcd8544.*=*|fb_ssd1289.*=*|fb_tls8204.*=*|fb_uc1611.*=*|fb_watterott.*=*|fbtft.*=*);;
        fbtft_device.*=*|fcoe.*=*|fdomain.*=*|fdomain_cs.*=*|fealnx.*=*|fintek-cir.*=*|firedtv.*=*|firestream.*=*);;
        firewire-ohci.*=*|firewire-sbp2.*=*|firewire-serial.*=*|firmware_class.*=*|flexfb.*=*|floppy.*=*|floppy=*);;
        fm_drv.*=*|fmc-chardev.*=*|fmc-fakedev.*=*|fmc-trivial.*=*|fmc-write-eeprom.*=*|fmc.*=*|fmvj18x_cs.*=*);;
        fnic.*=*|force_pal_cache_flush|forcedeth.*=*|forcepae|fotg210-hcd.*=*|fscache.*=*|fschmd.*=*|fscrypto.*=*);;
        fsi-core.*=*|ftdi-elan.*=*|ftdi_sio.*=*|ftl.*=*|ftrace=*|ftrace_dump_on_oops|ftrace_dump_on_oops=*);;
        ftrace_filter=*|ftrace_graph_filter=*|ftrace_graph_max_depth=*|ftrace_graph_notrace=*|ftrace_notrace=*);;
        fujitsu-laptop.*=*|fuse.*=*|g_ether.*=*|g_ffs.*=*|g_serial.*=*|gadgetfs.*=*|gamecon.*=*|gamecon.map2=*);;
        gamecon.map3=*|gamecon.map=*|gameport.*=*|gamma=*|garmin_gps.*=*|garp.*=*|gart_fix_e820=*|gb-loopback.*=*);;
        gcov_persist=*|gdth.*=*|geneve.*=*|gigaset.*=*|gl520sm.*=*|go7007-usb.*=*|go7007.*=*|goldfish|gp8psk-fe.*=*);;
        gpd-pocket-fan.*=*|gpio-ich.*=*|gpio-mockup.*=*|gpio-mockup.gpio_mockup_ranges|gpio-viperboard.*=*|gpt);;
        grcan.enable0=*|grcan.enable1=*|grcan.rxsize=*|grcan.select=*|grcan.txsize=*|greybus.*=*|gs_fpga.*=*|gsmi.*=*);;
        gspca_gl860.*=*|gspca_kinect.*=*|gspca_m5602.*=*|gspca_main.*=*|gspca_mr97310a.*=*|gspca_nw80x.*=*);;
        gspca_ov519.*=*|gspca_pac207.*=*|gspca_stv06xx.*=*|gspca_topro.*=*|gspca_xirlink_cit.*=*|gspca_zc3xx.*=*);;
        hackrf.*=*|hamachi.*=*|hangcheck-timer.*=*|hardened_usercopy=*|hardlockup_all_cpu_backtrace=*|hashdist=*);;
        hci_uart.*=*|hci_vhci.*=*|hcl=*|hd=*|hdaps.*=*|hdm_dim2.*=*|hdm_i2c.*=*|hdma.*=*|hdma_mgmt.*=*|hdpvr.*=*);;
        he.*=*|hest_disable|hexium_gemini.*=*|hexium_orion.*=*|hfc_usb.*=*|hfcmulti.*=*|hfcpci.*=*|hfcsusb.*=*);;
        hfi1.*=*|hgafb.*=*|hibernate=*|hid-apple.*=*|hid-corsair.*=*|hid-cp2112.*=*|hid-elo.*=*|hid-led.*=*);;
        hid-logitech-hidpp.*=*|hid-logitech.*=*|hid-magicmouse.*=*|hid-ntrig.*=*|hid-prodikeys.*=*|hid.*=*);;
        hid_apple.*=*|hid_logitech.*=*|hid_logitech_hidpp.*=*|highmem=*|highres=*|hisax.*=*|hisax=*);;
        hisax_fcpcipnp.*=*|hisax_st5481.*=*|hlt|hopper.*=*|horizon.*=*|hostap.*=*|hostap_cs.*=*|hostap_pci.*=*);;
        hostap_plx.*=*|hp100.*=*|hpet=*|hpet_mmap=*|hpilo.*=*|hpsa.*=*|hpwdt.*=*|hsi_char.*=*|hso.*=*|hugepages=*);;
        hugepagesz=*|hung_task_panic=*|hv_balloon.*=*|hv_netvsc.*=*|hv_nopvspin|hv_storvsc.*=*|hvc_iucv=*);;
        hvc_iucv_allow=*|hysdn.*=*|i2400m-usb.*=*|i2400m.*=*|i2c-algo-bit.*=*|i2c-algo-pca.*=*|i2c-ali15x3.*=*);;
        i2c-diolan-u2c.*=*|i2c-hid.*=*|i2c-i801.*=*|i2c-isch.*=*|i2c-ismt.*=*|i2c-kempld.*=*|i2c-parport-light.*=*);;
        i2c-parport.*=*|i2c-piix4.*=*|i2c-sis5595.*=*|i2c-sis630.*=*|i2c-stub.*=*|i2c-tiny-usb.*=*|i2c-viapro.*=*);;
        i2c-viperboard.*=*|i2c_algo_bit.*=*|i2c_bus=*|i2c_hid.*=*|i2c_i801.*=*|i3000_edac.*=*|i3200_edac.*=*|i40e.*=*);;
        i40iw.*=*|i5000_edac.*=*|i5400_edac.*=*|i6300esb.*=*|i7300_edac.*=*|i740fb.*=*|i7core_edac.*=*|i8042.*=*);;
        i8042.debug|i8042.direct|i8042.dumbkbd|i8042.kbdreset|i8042.noaux|i8042.nokbd|i8042.noloop|i8042.nomux);;
        i8042.nopnp|i8042.notimeout|i8042.reset|i8042.unlock|i8042.unmask_kbd_data|i810=*|i82975x_edac.*=*|i8k.force);;
        i8k.ignore_dmi|i8k.power_status|i8k.restricted|i915.*=*|i915.invert_brightness=*|iTCO_vendor_support.*=*);;
        iTCO_wdt.*=*|ib700wdt.*=*|ib_core.*=*|ib_ipoib.*=*|ib_iser.*=*|ib_isert.*=*|ib_mthca.*=*|ib_qib.*=*);;
        ib_srp.*=*|ib_srpt.*=*|ibm_rtl.*=*|ibmasm.*=*|ibmasr.*=*|icn=*|ide-core.nodma=*|ide-generic.probe-mask=*);;
        ide-pci-generic.all-generic-ide|ideapad-laptop.*=*|ideapad_slidebar.*=*|idle=*|idt77252.*=*|ie6xx_wdt.*=*);;
        ieee754=*|ifb.*=*|igb.*=*|igbvf.*=*|ignore_loglevel|ignore_rlimit_data|ihash_entries=*|ili922x.*=*);;
        ima.ahash_bufsize=*|ima.ahash_minsize=*|ima_appraise=*|ima_appraise_tcb|ima_canonical_fmt|ima_hash=*);;
        ima_policy=*|ima_tcb|ima_template=*|ima_template_fmt=*|imon.*=*|init=*|init_pkru=*|initcall_blacklist=*);;
        initcall_debug|initrd=*|inport.irq=*|int_pln_enable|integrity_audit=*|intel-ishtp.*=*|intel-rng.*=*);;
        intel_idle.*=*|intel_idle.max_cstate=*|intel_iommu=*|intel_ishtp.*=*|intel_oaktrail.*=*|intel_powerclamp.*=*);;
        intel_pstate=*|intel_soc_dts_thermal.*=*|intel_th.*=*|intremap=*|io7=*|io_delay=*|io_ti.*=*|ioatdma.*=*);;
        iomem=*|iommu.passthrough=*|iommu.strict=*|iommu=*|ip6_gre.*=*|ip6_tunnel.*=*|ip6table_filter.*=*);;
        ip6table_raw.*=*|ip=*|ip_gre.*=*|ip_set.*=*|ip_vs.*=*|ip_vs_ftp.*=*|ipaq.*=*|ipddp.*=*|iphase.*=*|ipip.*=*);;
        ipmi_devintf.*=*|ipmi_msghandler.*=*|ipmi_poweroff.*=*|ipmi_si.*=*|ipmi_ssif.*=*|ipmi_watchdog.*=*|ipr.*=*);;
        ips.*=*|iptable_filter.*=*|iptable_raw.*=*|ipv6.*=*|ipw2100.*=*|ipw2200.*=*|ipwireless.*=*|ir-kbd-i2c.*=*);;
        ir-usb.*=*|irda-usb.*=*|irlan.*=*|irqaffinity=*|irqchip.gicv2_force_probe=*|irqchip.gicv3_nolpi=*|irqfixup);;
        irqpoll|irtty-sir.*=*|isapnp=*|isci.*=*|iscsi_tcp.*=*|isl6423.*=*|isolcpus=*|it87.*=*|it8712f_wdt.*=*);;
        it87_wdt.*=*|itd1000.*=*|ite-cir.*=*|iucv=*|iuu_phoenix.*=*|ivrs_acpihid|ivrs_hpet|ivrs_ioapic|ivtv-alsa.*=*);;
        ivtv.*=*|ivtvfb.*=*|iw_cxgb3.*=*|iw_cxgb4.*=*|iw_nes.*=*|iwl3945.*=*|iwl4965.*=*|iwldvm.*=*|iwlegacy.*=*);;
        iwlmvm.*=*|iwlwifi.*=*|ix2505v.*=*|ixgb.*=*|ixgbe.*=*|ixgbevf.*=*|janz-cmodio.*=*|jfs.*=*|jmb38x_ms.*=*);;
        jme.*=*|js=*|jsm.*=*|k10temp.*=*|kafs.*=*|kasan_multi_shot|kbtab.*=*|keep_bootcon|keepinitrd|kempld-core.*=*);;
        kempld_wdt.*=*|kernel.*=*|kernelcapi.*=*|kernelcore=*|keyboard.*=*|keyspan_remote.*=*|kgdbdbgp=*|kgdboc=*);;
        kgdbwait|kmac=*|kmemleak=*|kpti=*|ks0108.*=*|ks0127.*=*|ks8851.*=*|ks8851_mll.*=*|ksocklnd.*=*|ksz884x.*=*);;
        kvm-amd.*=*|kvm-amd.nested=*|kvm-amd.npt=*|kvm-arm.vgic_v3_common_trap=*|kvm-arm.vgic_v3_group0_trap=*);;
        kvm-arm.vgic_v3_group1_trap=*|kvm-arm.vgic_v4_enable=*|kvm-intel.*=*|kvm-intel.emulate_invalid_guest_state=*);;
        kvm-intel.ept=*|kvm-intel.flexpriority=*|kvm-intel.nested=*|kvm-intel.unrestricted_guest=*);;
        kvm-intel.vmentry_l1d_flush=*|kvm-intel.vpid=*|kvm.*=*|kvm.enable_vmware_backdoor=*|kvm.ignore_msrs=*);;
        kvm.mmu_audit=*|kvm_amd.*=*|kvm_intel.*=*|l1oip.*=*|l1tf=*|l2cr=*|l3cr=*|l64781.*=*|lan78xx.*=*|lapic|lapic=*);;
        lapic_timer_c2_ok|ldusb.*=*|leds-clevo-mail.*=*|leds-ss4200.*=*|legousbtower.*=*|lg2160.*=*|lgdt3305.*=*);;
        lgdt3306a.*=*|lgdt330x.*=*|lgs8gxx.*=*|libahci.*=*|libata.*=*|libata.dma=*|libata.force=*|libata.ignore_hpa=*);;
        libata.noacpi|libcfs.*=*|libcxgbi.*=*|libertas.*=*|libertas_tf.*=*|libertas_tf_usb.*=*|libfc.*=*|libfcoe.*=*);;
        libiscsi.*=*|libiscsi_tcp.*=*|liquidio.*=*|liquidio_vf.*=*|lirc_zilog.*=*|lis3lv02d.*=*|lkkbd.*=*|lm93.*=*);;
        lnbp22.*=*|lnet.*=*|lnet_selftest.*=*|load_ramdisk=*|lockd.*=*|lockd.nlm_grace_period=*|lockd.nlm_tcpport=*);;
        lockd.nlm_timeout=*|lockd.nlm_udpport=*|locktorture.*=*|locktorture.nreaders_stress=*);;
        locktorture.nwriters_stress=*|locktorture.onoff_holdoff=*|locktorture.onoff_interval=*);;
        locktorture.shuffle_interval=*|locktorture.shutdown_secs=*|locktorture.stat_interval=*|locktorture.stutter=*);;
        locktorture.torture_type=*|locktorture.verbose=*|log_buf_len=*|logibm.irq=*|loglevel=*|logo.nologo|loop.*=*);;
        lp.*=*|lp=*|lpfc.*=*|lpj=*|lsm.debug|lsm=*|ltpc=*|m2m-deinterlace.*=*|m88rs2000.*=*|mISDN_core.*=*);;
        mISDN_dsp.*=*|mISDNinfineon.*=*|mac80211.*=*|mac80211_hwsim.*=*|machtype=*|machvec=*|machzwd.*=*|mantis.*=*);;
        mantis_core.*=*|matroxfb_base.*=*|matroxfb_crtc2.*=*|max1668.*=*|max2165.*=*|max63xx_wdt.*=*|max6650.*=*);;
        max_addr=*|max_loop=*|maxcpus=*|mb86a16.*=*|mc13783_ts.*=*|mcam-core.*=*|mce|mce=*|mcp251x.*=*|mcs7780.*=*);;
        md-mod.*=*|md=*|mdacon=*|megaraid.*=*|megaraid_mbox.*=*|megaraid_mm.*=*|megaraid_sas.*=*|mem=*|mem_encrypt=*);;
        mem_sleep_default=*|memblock=*|memchunk=*|memhp_default_state=*|memmap=*|memory-notifier-error-inject.*=*);;
        memory_corruption_check=*|memory_corruption_check_period=*|memory_corruption_check_size=*|memstick.*=*);;
        memtest=*|men_z135_uart.*=*|mena21_wdt.*=*|menf21bmc_wdt.*=*|metronomefb.*=*|meye.*=*|mfgpt_irq=*|mfgptfix);;
        mga=*|mgag200.*=*|min_addr=*|mini2440=*|mk712.*=*|mkiss.*=*|mlx4_core.*=*|mlx4_en.*=*|mlx4_ib.*=*);;
        mlx5_core.*=*|mmc_block.*=*|mmc_core.*=*|mminit_loglevel=*|module.*=*|module.async_probe|module.dyndbg);;
        module.dyndbg=*|module.sig_enforce|module_blacklist=*|mousedev.*=*|mousedev.tap_time=*|mousedev.xres=*);;
        mousedev.yres=*|movable_node|movablecore=*|moxa.*=*|mpt3sas.*=*|mptbase.*=*|mptfc.*=*|mptsas.*=*|mptspi.*=*);;
        mrp.*=*|msi-laptop.*=*|msi2500.*=*|msp3400.*=*|mspro_block.*=*|mt2060.*=*|mt2063.*=*|mt20xx.*=*|mt2131.*=*);;
        mt2266.*=*|mt312.*=*|mt352.*=*|mt9v011.*=*|mt9v022.*=*|mtd_nandbiterrs.*=*|mtd_oobtest.*=*|mtd_pagetest.*=*);;
        mtd_readtest.*=*|mtd_speedtest.*=*|mtd_stresstest.*=*|mtd_subpagetest.*=*|mtd_torturetest.*=*|mtdoops.*=*);;
        mtdparts=*|mtdram.*=*|mtdset=*|mtdswap.*=*|mtouchusb.raw_coordinates=*|mtrr_chunk_size=*|mtrr_gran_size=*);;
        mtrr_spare_reg_nr=*|multitce=*|mwave.*=*|mwifiex.*=*|mwl8k.*=*|mxb.*=*|mxl111sf-demod.*=*|mxl111sf-tuner.*=*);;
        mxl5007t.*=*|mxser.*=*|myri10ge.*=*|n2=*|n411.*=*|n_gsm.*=*|n_hdlc.*=*|nandsim.*=*|natsemi.*=*|nbd.*=*);;
        nct6683.*=*|nct6775.*=*|ndiswrapper.*=*|ne2k-pci.*=*|neofb.*=*|net2280.*=*|netconsole.*=*);;
        netdev-notifier-error-inject.*=*|netdev=*|netjet.*=*|netpoll.*=*|netpoll.carrier_timeout=*|netrom.*=*);;
        netup-unidvb.*=*|netxen_nic.*=*|nf_conntrack.*=*|nf_conntrack.acct=*|nf_conntrack_amanda.*=*);;
        nf_conntrack_ftp.*=*|nf_conntrack_h323.*=*|nf_conntrack_ipv4.*=*|nf_conntrack_irc.*=*);;
        nf_conntrack_netbios_ns.*=*|nf_conntrack_sane.*=*|nf_conntrack_sip.*=*|nf_conntrack_snmp.*=*);;
        nf_conntrack_tftp.*=*|nf_nat_snmp_basic.*=*|nfcmrvl_uart.*=*|nfit.*=*|nfs.*=*|nfs.cache_getent=*);;
        nfs.cache_getent_timeout=*|nfs.callback_nr_threads=*|nfs.callback_tcpport=*|nfs.enable_ino64=*);;
        nfs.idmap_cache_timeout=*|nfs.max_session_cb_slots=*|nfs.max_session_slots=*|nfs.nfs4_disable_idmapping=*);;
        nfs.nfs4_unique_id=*|nfs.recover_lost_locks|nfs.send_implementation_id|nfs4.layoutstats_timer);;
        nfs_layout_flexfiles.*=*|nfs_layout_nfsv41_files.*=*|nfsaddrs=*|nfsd.*=*|nfsd.nfs4_disable_idmapping=*);;
        nfsroot=*|nfsrootdebug|nfsv4.*=*|ngene.*=*|ni903x_wdt.*=*|ni_65xx.*=*|nic7018_wdt.*=*|nicstar.*=*|nicvf.*=*);;
        niu.*=*|nmclan_cs.*=*|nmi_debug=*|nmi_watchdog=*|no-kvmapf|no-kvmclock|no-scroll|no-steal-acc);;
        no-vmw-sched-clock|no387|no5lvl|no_console_suspend|no_debug_objects|no_file_caps|no_timer_check|noaliencache);;
        noalign|noaltinstr|noapic|noautogroup|nobats|nocache|noclflush|nodelayacct|nodsp|noefi|noexec|noexec32|nofpu);;
        nofxsr|nohalt|nohibernate|nohlt|nohugeiomap|nohz=*|nohz_full=*|noinitrd|nointremap|nointroute|noinvpcid);;
        noiotrap|noirqdebug|noisapnp|nojitter|nokaslr|nolapic|nolapic_timer|noltlbs|nomca|nomce|nomfgpt|nomodule);;
        nompx|nonmi_ipi|nopat|nopcid|nopku|nopti|norandmaps|nordrand|noreplace-smp|noresume|nosbagart|nosep|nosmap);;
        nosmep|nosmp|nosmt|nosoftlockup|nospec_store_bypass_disable|nospectre_v1|nospectre_v2|nosync|nouveau.*=*);;
        nowatchdog|nowb|nox2apic|noxsave|noxsaveopt|noxsaves|nozomi.*=*|nps_mtm_hs_ctr=*|nptcg=*|nr_cpus=*|nr_uarts=*);;
        ns83820.*=*|nsc-ircc.*=*|ntb_hw_intel.*=*|ntb_perf.*=*|ntb_pingpong.*=*|ntb_transport.*=*|null_blk.*=*);;
        numa_balancing=*|numa_zonelist_order=*|nuvoton-cir.*=*|nv_tco.*=*|nvidia.*=*|nvidiafb.*=*|nvme-core.*=*);;
        nvme-rdma.*=*|nvme.*=*|nvmet-rdma.*=*|nxt200x.*=*|nxt6000.*=*|obdclass.*=*|ocfb.*=*|ocfs2_dlmfs.*=*);;
        ohci-hcd.*=*|ohci1394_dma=*|olpc_ec_timeout=*|omap_mux=*|onenand.*=*|onenand.bdry=*|oops=*|oprofile.*=*);;
        oprofile.cpu_type=*|oprofile.timer=*|or51132.*=*|or51211.*=*|orangefs.*=*|orinoco.*=*|orinoco_cs.*=*|osc.*=*);;
        osst.*=*|ov7670.*=*|overlay.*=*|oxu210hp-hcd.*=*|p54common.*=*|p54spi.*=*|page_owner=*|page_poison=*);;
        panel.*=*|panic=*|panic_on_warn|panic_print=*|parkbd.*=*|parkbd.mode=*|parkbd.port=*|parport=*|parport_cs.*=*);;
        parport_init_mode=*|parport_pc.*=*|pata_ali.*=*|pata_it821x.*=*|pata_legacy.*=*|pause_on_oops=*|pc300too.*=*);;
        pc87360.*=*|pc87413_wdt.*=*|pc87427.*=*|pcbit=*|pcd.|pcd.*=*|pcf8591.*=*|pch_udc.*=*|pci-stub.*=*);;
        pci200syn.*=*|pci=*|pci_hotplug.*=*|pcie_aspm.*=*|pcie_aspm=*|pcie_pme=*|pcie_port_pm=*|pcie_ports=*);;
        pciehp.*=*|pcmcia.*=*|pcmcia_core.*=*|pcmcia_rsrc.*=*|pcmciamtd.*=*|pcmv=*|pcnet32.*=*|pcnet_cs.*=*);;
        pcwd_pci.*=*|pcwd_usb.*=*|pd.|pd.*=*|pd6729.*=*|pd_ignore_unused|pdcchassis=*|pegasus.*=*|percpu_alloc=*);;
        perf_v4_pmi=*|pf.|pf.*=*|pg.|pg.*=*|phram.*=*|pirq=*|pktgen.*=*|plip.*=*|plip=*|pluto2.*=*);;
        pm-notifier-error-inject.*=*|pm2fb.*=*|pm3fb.*=*|pmc551.*=*|pmcraid.*=*|pmtmr=*|pnd2_edac.*=*|pnp.debug=*);;
        pnp_reserve_dma=*|pnp_reserve_io=*|pnp_reserve_irq=*|pnp_reserve_mem=*|pnpacpi=*|pnpbios=*|ports=*);;
        powersave=*|ppc_strict_facility_enable|ppc_tm=*|ppp_async.*=*|ppp_generic.*=*|pps_parport.*=*);;
        prime_numbers.*=*|print-fatal-signals=*|printk.*=*|printk.always_kmsg_dump=*|printk.devkmsg=*|printk.time=*);;
        prism2_usb.*=*|prism54.*=*|processor.*=*|processor.max_cstate=*|processor.nocst|profile=*|prompt_ramdisk=*);;
        psi=*|psmouse.*=*|psmouse.proto=*|psmouse.rate=*|psmouse.resetafter=*|psmouse.resolution=*);;
        psmouse.smartscroll=*|pstore.*=*|pstore.backend=*|pt.|pt.*=*|pti=*|ptlrpc.*=*|pty.legacy_count=*);;
        pulse8-cec.*=*|pvrusb2.*=*|pwc.*=*|qede.*=*|qedf.*=*|qedi.*=*|qla1280.*=*|qla2xxx.*=*|qla3xxx.*=*|qla4xxx.*=*);;
        qlcnic.*=*|qlge.*=*|quiet|qxl.*=*|r128=*|r592.*=*|r8169.*=*|r8188eu.*=*|r8192e_pci.*=*|r8192u_usb.*=*);;
        r820t.*=*|r852.*=*|r8712u.*=*|r8723bs.*=*|r8822be.*=*|radeon.*=*|radeonfb.*=*|radio-bcm2048.*=*);;
        radio-i2c-si470x.*=*|radio-ma901.*=*|radio-maxiradio.*=*|radio-mr800.*=*|radio-platform-si4713.*=*);;
        radio-si470x-common.*=*|radio-si470x-usb.*=*|radio-tea5764.*=*|radio-usb-si470x.*=*|radio-wl1273.*=*);;
        raid1.*=*|raid10.*=*|raid456.*=*|raid=*|ramdisk_size=*|ramoops.*=*|random.*=*|random.trust_cpu=*|ras=*);;
        raw.*=*|ray_cs.*=*|rbd.*=*|rc-core.*=*|rc-loopback.*=*|rcu_nocb_poll|rcu_nocbs=*|rcupdate.*=*);;
        rcupdate.rcu_cpu_stall_suppress=*|rcupdate.rcu_cpu_stall_timeout=*|rcupdate.rcu_expedited=*);;
        rcupdate.rcu_normal=*|rcupdate.rcu_normal_after_boot=*|rcupdate.rcu_self_test=*);;
        rcupdate.rcu_task_stall_timeout=*|rcuperf.gp_async=*|rcuperf.gp_async_max=*|rcuperf.gp_exp=*);;
        rcuperf.holdoff=*|rcuperf.nreaders=*|rcuperf.nwriters=*|rcuperf.perf_type=*|rcuperf.shutdown=*);;
        rcuperf.verbose=*|rcuperf.writer_holdoff=*|rcutorture.fqs_duration=*|rcutorture.fqs_holdoff=*);;
        rcutorture.fqs_stutter=*|rcutorture.fwd_progress=*|rcutorture.fwd_progress_div=*);;
        rcutorture.fwd_progress_holdoff=*|rcutorture.fwd_progress_need_resched=*|rcutorture.gp_cond=*);;
        rcutorture.gp_exp=*|rcutorture.gp_normal=*|rcutorture.gp_sync=*|rcutorture.n_barrier_cbs=*);;
        rcutorture.nfakewriters=*|rcutorture.nreaders=*|rcutorture.object_debug=*|rcutorture.onoff_holdoff=*);;
        rcutorture.onoff_interval=*|rcutorture.shuffle_interval=*|rcutorture.shutdown_secs=*|rcutorture.stall_cpu=*);;
        rcutorture.stall_cpu_holdoff=*|rcutorture.stall_cpu_irqsoff=*|rcutorture.stat_interval=*|rcutorture.stutter=*);;
        rcutorture.test_boost=*|rcutorture.test_boost_duration=*|rcutorture.test_boost_interval=*);;
        rcutorture.test_no_idle_hz=*|rcutorture.torture_type=*|rcutorture.verbose=*|rcutree.*=*|rcutree.blimit=*);;
        rcutree.dump_tree=*|rcutree.gp_cleanup_delay=*|rcutree.gp_init_delay=*|rcutree.gp_preinit_delay=*);;
        rcutree.jiffies_till_first_fqs=*|rcutree.jiffies_till_next_fqs=*|rcutree.jiffies_till_sched_qs=*);;
        rcutree.kthread_prio=*|rcutree.qhimark=*|rcutree.qlowmark=*|rcutree.rcu_fanout_exact=*);;
        rcutree.rcu_fanout_leaf=*|rcutree.rcu_idle_gp_delay=*|rcutree.rcu_idle_lazy_gp_delay=*);;
        rcutree.rcu_kick_kthreads=*|rcutree.rcu_nocb_leader_stride=*|rcutree.sysrq_rcu=*|rdinit=*|rdma_rxe.*=*);;
        rds.*=*|rds_rdma.*=*|rdt=*|reboot=*|redboot.*=*|redrat3.*=*|relax_domain_level=*|reserve=*|reservelow=*);;
        reservetop=*|reset_devices|resume=*|resume_offset=*|resumedelay=*|resumewait|retain_initrd|rfcomm.*=*);;
        rfd_ftl.*=*|rfkill.*=*|rfkill.default_state=*|rfkill.master_switch_mode=*|rhash_entries=*|ring3mwait=*);;
        rio-scan.*=*|rio_cm.*=*|rio_mport_cdev.*=*|rivafb.*=*|rmi_core.*=*|rndis_wlan.*=*|rng-core.*=*|rng_core.*=*);;
        ro|rockchip.usb_uart|rocket.*=*|rodata=*|root=*|rootdelay=*|rootflags=*|rootfstype=*|rootwait|rose.*=*);;
        rproc_mem=*|rsi_usb.*=*|rsxx.*=*|rt2500usb.*=*|rt2800pci.*=*|rt2800usb.*=*|rt61pci.*=*|rt73usb.*=*);;
        rtc-ds1374.*=*|rtc-m41t80.*=*|rtc_cmos.*=*|rtl2832_sdr.*=*|rtl8188ee.*=*|rtl8192ce.*=*|rtl8192cu.*=*);;
        rtl8192de.*=*|rtl8192ee.*=*|rtl8192se.*=*|rtl8723ae.*=*|rtl8723be.*=*|rtl8821ae.*=*|rtl8xxxu.*=*|rts5208.*=*);;
        rtsx_pci.*=*|rtsx_usb.*=*|rw|rxrpc.*=*|s2255drv.*=*|s2io.*=*|s390_iommu=*|s3fb.*=*|s5h1409.*=*|s5h1411.*=*);;
        s5h1420.*=*|s921.*=*|sa1100ir|saa6588.*=*|saa7110.*=*|saa7115.*=*|saa7127.*=*|saa7134-alsa.*=*);;
        saa7134-dvb.*=*|saa7134-empress.*=*|saa7134.*=*|saa7146.*=*|saa7146_vv.*=*|saa7164.*=*|saa717x.*=*);;
        saa7185.*=*|safe_serial.*=*|samsung-laptop.*=*|samsung-q10.*=*|samsung-sxgbe.*=*|sata_mv.*=*|sata_nv.*=*);;
        sata_sil.*=*|sata_sil24.*=*|sata_via.*=*|savagefb.*=*|sb_edac.*=*|sbc60xxwdt.*=*|sbc_epx_c3.*=*);;
        sbc_fitpc2_wdt.*=*|sbni.*=*|sbni=*|sbs-battery.*=*|sbs.*=*|sc1200wdt.*=*|sc92031.*=*|sch311x_wdt.*=*);;
        sch56xx-common.*=*|sch_htb.*=*|sch_teql.*=*|sched_debug|schedstats=*|scsi_debug.*=*|scsi_dh_alua.*=*);;
        scsi_dh_rdac.*=*|scsi_mod.*=*|scsi_transport_fc.*=*|scsi_transport_iscsi.*=*|sctp.*=*|sdhci.*=*);;
        sdricoh_cs.*=*|security=*|sedlbauer_cs.*=*|selinux=*|ser_gigaset.*=*|serial_cs.*=*|serial_ir.*=*|serialnumber);;
        sfc-falcon.*=*|sfc.*=*|sg.*=*|shapers=*|shark2.*=*|show_lapic=*|shpchp.*=*|si2165.*=*|si21xx.*=*|si4713.*=*);;
        sierra.*=*|simeth=*|simscsi=*|sir_ir.*=*|sis-agp.*=*|sis190.*=*|sis5595.*=*|sis900.*=*|sisfb.*=*);;
        sisusbvga.*=*|sit.*=*|sja1000_isa.*=*|skd.*=*|skew_tick=*|skge.*=*|skx_edac.*=*|sky2.*=*|slab_common.*=*);;
        slab_max_order=*|slab_nomerge|slcan.*=*|slip.*=*|slram.*=*|slram=*|slub_debug|slub_debug=*|slub_max_order=*);;
        slub_memcg_sysfs=*|slub_min_objects=*|slub_min_order=*|slub_nomerge|sm750fb.*=*|sm_ftl.*=*|smart2=*);;
        smartpqi.*=*|smc91c92_cs.*=*|smipcie.*=*|smm665.*=*|smsc-ircc2.*=*|smsc-ircc2.ircc_cfg=*);;
        smsc-ircc2.ircc_dma=*|smsc-ircc2.ircc_fir=*|smsc-ircc2.ircc_irq=*|smsc-ircc2.ircc_sir=*);;
        smsc-ircc2.ircc_transceiver=*|smsc-ircc2.nopnp|smsc37b787_wdt.*=*|smsc47b397.*=*|smsc47m1.*=*|smsc75xx.*=*);;
        smsc911x.*=*|smsc9420.*=*|smsc95xx.*=*|smscufx.*=*|smsdvb.*=*|smsmdtv.*=*|smt|snd-ac97-codec.*=*);;
        snd-ad1889.*=*|snd-ali5451.*=*|snd-aloop.*=*|snd-als300.*=*|snd-als4000.*=*|snd-asihpi.*=*);;
        snd-atiixp-modem.*=*|snd-atiixp.*=*|snd-au8810.*=*|snd-au8820.*=*|snd-au8830.*=*|snd-aw2.*=*|snd-azt3328.*=*);;
        snd-bebob.*=*|snd-bt87x.*=*|snd-ca0106.*=*|snd-cmipci.*=*|snd-cs4281.*=*|snd-cs46xx.*=*|snd-ctxfi.*=*);;
        snd-darla20.*=*|snd-darla24.*=*|snd-dummy.*=*|snd-echo3g.*=*|snd-emu10k1.*=*|snd-emu10k1x.*=*|snd-ens1370.*=*);;
        snd-ens1371.*=*|snd-es1938.*=*|snd-es1968.*=*|snd-fireworks.*=*|snd-fm801.*=*|snd-gina20.*=*|snd-gina24.*=*);;
        snd-hda-codec-hdmi.*=*|snd-hda-codec.*=*|snd-hda-intel.*=*|snd-hdmi-lpe-audio.*=*|snd-hdsp.*=*|snd-hdspm.*=*);;
        snd-ice1712.*=*|snd-ice1724.*=*|snd-indigo.*=*|snd-indigodj.*=*|snd-indigodjx.*=*|snd-indigoio.*=*);;
        snd-indigoiox.*=*|snd-intel8x0.*=*|snd-intel8x0m.*=*|snd-korg1212.*=*|snd-layla20.*=*|snd-layla24.*=*);;
        snd-lola.*=*|snd-lx6464es.*=*|snd-maestro3.*=*|snd-mia.*=*|snd-mixart.*=*|snd-mona.*=*|snd-mpu401.*=*);;
        snd-mtpav.*=*|snd-mts64.*=*|snd-nm256.*=*|snd-opl3-synth.*=*|snd-oxygen.*=*|snd-pcm-oss.*=*|snd-pcm.*=*);;
        snd-pcsp.*=*|snd-pcxhr.*=*|snd-pdaudiocf.*=*|snd-portman2x4.*=*|snd-rawmidi.*=*|snd-riptide.*=*|snd-rme32.*=*);;
        snd-rme96.*=*|snd-rme9652.*=*|snd-seq-dummy.*=*|snd-seq-midi.*=*|snd-seq-oss.*=*|snd-seq.*=*);;
        snd-serial-u16550.*=*|snd-soc-alc5623.*=*|snd-soc-core.*=*|snd-soc-rt5645.*=*|snd-soc-rt5670.*=*);;
        snd-soc-sst-bytcr-rt5640.*=*|snd-soc-wm8753.*=*|snd-sonicvibes.*=*|snd-timer.*=*|snd-trident.*=*);;
        snd-ua101.*=*|snd-usb-6fire.*=*|snd-usb-audio.*=*|snd-usb-caiaq.*=*|snd-usb-hiface.*=*|snd-usb-us122l.*=*);;
        snd-usb-usx2y.*=*|snd-via82xx-modem.*=*|snd-via82xx.*=*|snd-virmidi.*=*|snd-virtuoso.*=*|snd-vx222.*=*);;
        snd-vxpocket.*=*|snd-ymfpci.*=*|snd.*=*|snd_hda_codec.*=*|snd_hda_codec_hdmi.*=*|snd_hda_intel.*=*);;
        snd_pcm.*=*|snd_timer.*=*|snic.*=*|softdog.*=*|softlockup_all_cpu_backtrace=*|softlockup_panic=*|solo6x10.*=*);;
        solos-pci.*=*|sony-btf-mpx.*=*|sony-laptop.*=*|sonypi.*=*|soundcore.*=*|sp5100_tco.*=*|sp8870.*=*|sp887x.*=*);;
        speakup.*=*|speakup_acntsa.*=*|speakup_apollo.*=*|speakup_audptr.*=*|speakup_bns.*=*|speakup_decext.*=*);;
        speakup_dectlk.*=*|speakup_dummy.*=*|speakup_ltlk.*=*|speakup_soft.*=*|speakup_spkout.*=*|speakup_txprt.*=*);;
        spec_store_bypass_disable=*|spectre_v2=*|spectre_v2_user=*|spectrum_cs.*=*|speedfax.*=*|speedtch.*=*);;
        spi-loopback-test.*=*|spia_fio_base=*|spia_io_base=*|spia_peddr=*|spia_pedr=*|spidev.*=*|spurious.*=*);;
        sr_mod.*=*|srcutree.*=*|srcutree.counter_wrap_check|srcutree.exp_holdoff|ssbd=*|sstfb.*=*|st.*=*);;
        stack_guard_gap=*|stacktrace|stacktrace_filter=*|starfire.*=*|stb0899.*=*|stb6000.*=*|stb6100.*=*|stex.*=*);;
        sti=*|sti_font=*|stifb=*|stir4200.*=*|stk1160.*=*|stkwebcam.*=*|stm_heartbeat.*=*|stmmac.*=*|stv0288.*=*);;
        stv0299.*=*|stv0367.*=*|stv0900.*=*|stv090x.*=*|stv6110.*=*|stv6110x.*=*|sundance.*=*|sunhme.*=*|sunrpc.*=*);;
        sunrpc.max_resvport=*|sunrpc.min_resvport=*|sunrpc.pool_mode=*|sunrpc.svc_rpc_per_connection_limit=*);;
        sunrpc.tcp_slot_table_entries=*|sunrpc.udp_slot_table_entries=*|sur40.*=*|suspend.*=*|suspend.pm_test_delay=*);;
        swapaccount=*|swiotlb=*|switches=*|sx8.*=*|sym53c8xx.*=*|synaptics_i2c.*=*|synclink.*=*|synclink_cs.*=*);;
        synclink_gt.*=*|synclinkmp.*=*|syscall.*=*|sysfs.deprecated=*|sysrq.*=*|sysrq_always_enabled);;
        target_core_user.*=*|tc-dwc-g210-pci.*=*|tcm_fc.*=*|tcp_bic.*=*|tcp_cdg.*=*|tcp_cubic.*=*|tcp_dctcp.*=*);;
        tcp_htcp.*=*|tcp_hybla.*=*|tcp_illinois.*=*|tcp_nv.*=*|tcp_vegas.*=*|tcpmhash_entries=*|tcrypt.*=*);;
        tda10021.*=*|tda10048.*=*|tda1004x.*=*|tda10086.*=*|tda18271.*=*|tda7432.*=*|tda8083.*=*|tda826x.*=*);;
        tda827x.*=*|tda8290.*=*|tda9840.*=*|tda9887.*=*|tdfx=*|tdfxfb.*=*|tea5761.*=*|tea5767.*=*|tea6415c.*=*);;
        tea6420.*=*|tekram-sir.*=*|teles_cs.*=*|test-drm_mm.*=*|test_bpf.*=*|test_power.*=*|test_suspend=*|tg3.*=*);;
        thash_entries=*|thermal.*=*|thermal.act=*|thermal.crt=*|thermal.nocrt=*|thermal.off=*|thermal.psv=*);;
        thermal.tzp=*|thinkpad_acpi.*=*|thmc50.*=*|threadirqs|ti_usb_3410_5052.*=*|tifm_ms.*=*|tifm_sd.*=*);;
        tinydrm.*=*|tlan.*=*|tm6000-alsa.*=*|tm6000-dvb.*=*|tm6000.*=*|tmem|tmem.*=*|tmem.cleancache=*);;
        tmem.frontswap=*|tmem.selfballooning=*|tmem.selfshrinking=*|toim3232-sir.*=*|topology=*|topology_updates=*);;
        toshiba_acpi.*=*|tp720=*|tp_printk|tpm.*=*|tpm_suspend_pcr=*|tpm_tis.*=*|trace_buf_size=*|trace_event=*);;
        trace_options=*|traceoff_on_warning|transparent_hugepage=*|tridentfb.*=*|tsc=*|tsi721_mport.*=*|ttusb_dec.*=*);;
        tulip.*=*|tuner-simple.*=*|tuner-xc2028.*=*|tuner.*=*|turbografx.*=*|turbografx.map2=*|turbografx.map3=*);;
        turbografx.map=*|tvaudio.*=*|tvp5150.*=*|tw5864.*=*|tw68.*=*|tw686x.*=*|twofish-x86_64-3way.*=*|typhoon.*=*);;
        u132-hcd.*=*|ubi.*=*|ucb1400_ts.*=*|udbg-immortal|udl.*=*|udlfb.*=*|ueagle-atm.*=*|uhash_entries=*);;
        uhci-hcd.*=*|uhci-hcd.ignore_oc=*|uhci_hcd.*=*|uio_pruss.*=*|uli526x.*=*|umem.*=*|ums-realtek.*=*);;
        unknown_nmi_panic|upd64031a.*=*|upd64083.*=*|usb-storage.*=*|usb-storage.delay_use=*|usb-storage.quirks=*);;
        usb_f_uvc.*=*|usb_gigaset.*=*|usb_storage.*=*|usbatm.*=*|usbcore.*=*|usbcore.authorized_default=*);;
        usbcore.autosuspend=*|usbcore.blinkenlights=*|usbcore.initial_descriptor_timeout=*|usbcore.nousb);;
        usbcore.old_scheme_first=*|usbcore.quirks=*|usbcore.usbfs_memory_mb=*|usbcore.usbfs_snoop=*);;
        usbcore.usbfs_snoop_max=*|usbcore.use_both_schemes=*|usbhid.*=*|usbhid.jspoll=*|usbhid.kbpoll=*);;
        usbhid.mousepoll=*|usbip-core.*=*|usbip-vudc.*=*|usblp.*=*|usbnet.*=*|usbserial.*=*|usbtest.*=*);;
        usbtouchscreen.*=*|usbvision.*=*|user_debug=*|userpte=*|usnic_verbs.*=*|uvcvideo.*=*|uvesafb.*=*);;
        v4l2-mem2mem.*=*|vboxdrv.*=*|vboxsf.*=*|vboxvideo.*=*|vcan.*=*|vdso32=*|vdso=*|vector=*|ves1820.*=*);;
        ves1x93.*=*|vfb.*=*|vfio-pci.*=*|vfio_iommu_type1.*=*|vga=*|vhost.*=*|vhost_net.*=*|via-camera.*=*);;
        via-ircc.*=*|via-rhine.*=*|via-velocity.*=*|via686a.*=*|via_wdt.*=*|viafb.*=*|video.*=*);;
        video.brightness_switch_enabled=*|video=*|videobuf-core.*=*|videobuf-dma-sg.*=*|videobuf-dvb.*=*);;
        videobuf-vmalloc.*=*|videobuf2-common.*=*|videobuf2-core.*=*|videobuf2-dma-sg.*=*|videobuf2-v4l2.*=*);;
        videocodec.*=*|virtio-gpu.*=*|virtio_balloon.*=*|virtio_blk.*=*|virtio_mmio.device=*|virtio_net.*=*);;
        virtio_pci.*=*|vivid.*=*|vlsi_ir.*=*|vm_debug|vm_debug=*|vmalloc=*|vmcp_cma=*|vmhalt=*|vmpanic=*|vmpoff=*);;
        vmw_pvscsi.*=*|vmw_vmci.*=*|vmwgfx.*=*|vpx3220.*=*|vsyscall=*|vt.*=*|vt.color=*|vt.cur_default=*);;
        vt.default_blu=*|vt.default_grn=*|vt.default_red=*|vt.default_utf8=*|vt.global_cursor_default=*|vt.italic=*);;
        vt.underline=*|vt1211.*=*|vt6656_stage.*=*|vt8231.*=*|vt8623fb.*=*|vub300.*=*|vxge.*=*|vxlan.*=*);;
        w1_ds28e04.*=*|w1_ds28e17.*=*|w1_therm.*=*|w6692.*=*|w83627ehf.*=*|w83627hf.*=*|w83627hf_wdt.*=*|w83781d.*=*);;
        w83791d.*=*|w83792d.*=*|w83793.*=*|w83795.*=*|w83877f_wdt.*=*|w83977af_ir.*=*|w83977f_wdt.*=*|w83l786ng.*=*);;
        wacom.*=*|wafer5823wdt.*=*|walkera0701.*=*|watchdog|watchdog.*=*|wbsd.*=*|wcn36xx.*=*|wdat_wdt.*=*);;
        wdt_pci.*=*|wil6210.*=*|wimax.*=*|winbond-840.*=*|winbond-cir.*=*|wire.*=*|wl.*=*|wl12xx.*=*|wl18xx.*=*);;
        wlcore.*=*|wlcore_sdio.*=*|wm831x_wdt.*=*|wm8739.*=*|wm97xx-ts.*=*|wmi.*=*|workqueue.*=*);;
        workqueue.debug_force_rr_cpu|workqueue.disable_numa|workqueue.power_efficient|workqueue.watchdog_thresh=*);;
        wusbcore.*=*|x25_asy.*=*|x2apic_phys|x38_edac.*=*|x86_intel_mid_timer=*|x86_pkg_temp_thermal.*=*|xc4000.*=*);;
        xc5000.*=*|xen-acpi-processor.*=*|xen-blkback.*=*|xen-blkfront.*=*|xen-gntalloc.*=*|xen-gntdev.*=*);;
        xen-netback.*=*|xen-netfront.*=*|xen-pciback.*=*|xen-pcifront.*=*|xen-privcmd.*=*|xen-scsiback.*=*);;
        xen_512gb_limit|xen_emul_unplug=*|xen_kbdfront.*=*|xen_nopv|xen_nopvspin|xen_scrub_pages=*|xen_wdt.*=*);;
        xgifb.*=*|xhci-hcd.*=*|xhci-hcd.quirks|xhci_hcd.*=*|xirc2ps_cs.*=*|xirc2ps_cs=*|xpad.*=*|xt_recent.*=*);;
        xusbatm.*=*|yellowfin.*=*|yenta_socket.*=*|zd1201.*=*|zd1301.*=*|zd1301_demod.*=*|ziirave_wdt.*=*|zl10036.*=*);;
        zl10039.*=*|zl10353.*=*|zl6100.*=*|zr36016.*=*|zr36050.*=*|zr36060.*=*|zr36067.*=*|zr364xx.*=*|zram.*=*);;
        zswap.*=*);;
        amd_pstate=*);;
        nomodeset|*.modeset=*);;
        splash=*|fbcon=*);;
        grubsave);;
        kernel=*);;
        extra=*);;


        *) printf "%s " "$param" ;;
        esac
    done

    if [ -n "$disable" ]; then
        # If the ## expression matches then the resulting string length is zero
        [ "${disable##*[l]*}" ] ||      touch /live/config/lean
        [ "${disable##*[m]*}" ] ||      touch /live/config/mean
        [ "${disable##*[x]*}" ] ||      touch /live/config/xtra-lean
        [ "${disable##*[d]*}" ] ||      touch /live/config/no-dbus
    fi

}
