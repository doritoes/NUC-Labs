import XenAPI
import ssl

HOST_IP = "192.168.99.209"
USERNAME = "root"
PASSWORD = "hostpasswordsecret"
VM_LIST = ('sms', 'firewall1a', 'firewall1b', 'firewall2a', 'firewall2b', 'firewall3a', 'firewall3b')
VM_NAME = "firewall1a"

def main():
    # disable https certificate checking
    if hasattr(ssl, '_create_unverified_context'):
        ssl._create_default_https_context = ssl._create_unverified_context
    url = f"https://{HOST_IP}"
    session = XenAPI.Session(url)
    try:
        print(f"Connecting to {HOST_IP}...")
        session.xenapi.login_with_password(USERNAME, PASSWORD, "1.0", "python-script")
    except XenAPI.Failure as e:
        print(f"XenAPI Error: {e}")
    except Exception as e:
        print(f"General Error: {e}")
    for vm in VM_LIST:
        print(f"Searching for VM: {VM_NAME}...")
        vms = session.xenapi.VM.get_by_name_label(VM_NAME)
        if len(vms) == 0:
            print(f"Error: VM '{VM_NAME}' not found.")
            continue
        vm_ref = vms[0]
        vif_refs = session.xenapi.VM.get_VIFs(vm_ref)
        if not vif_refs:
            print("No network interfaces found on this VM.")
            continue
        print(f"Found {len(vif_refs)} interface(s). Updating settings...")
        for vif in vif_refs:
            device = session.xenapi.VIF.get_device(vif)
            other_config = session.xenapi.VIF.get_other_config(vif)
            # ethtool-tx transmit checksum offload
            # ethtool-tso TCP segmentation offload
            # ethtool-ufo UDP fragmentation offload
            # ethtool-gro generic receive offload
            if other_config.get('ethtool-tx') == 'off':
                print(f"  Interface {device}: TX Checksumming already disabled.")
            else:
                print(f"Disabling TX checksumming for interface {device}"
                other_config['ethtool-tx'] = 'off'
                try:
                    session.xenapi.VIF.set_other_config(vif, other_config)
                    print(f" - Interface {device}: TX Checksumming disabled (ethtool-tx: off)")
                    power_state = session.xenapi.VM.get_power_state(vm_ref)
                    if power_state == 'Running':
                        print("  [!] VM is RUNNING. A reboot is required for these changes to take effect.")
                    elif power_state == 'Halted':
                        print("  [i] VM is Halted. Changes will apply on next boot.")
                    else:
                        print(f"  [i] VM state is {power_state}.")
                            print("Note: You must reboot the VM or unplug/plug the VIFs for changes to take effect.")
                    print("")
                except XenAPI.Failure as e:
                    print(f"XenAPI Error: {e}")
                except Exception as e:
                    print(f"General Error: {e}")            
        try:
            session.xenapi.logout()
        except:
            pass
if __name__ == "__main__":
    main()
