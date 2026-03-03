#!/usr/bin/env python3
import subprocess
import sys
import json
import time

def run_su_command(command):
    """Executes a command via su and returns the output."""
    try:
        # We use su -c to run the command with root privileges on the android device
        result = subprocess.run(['su', '-c', command], capture_output=True, text=True, timeout=10)
        return result.stdout.strip()
    except subprocess.TimeoutExpired:
        return ""
    except Exception as e:
        return ""

def layer1_process_check(package_name):
    """
    Layer 1: Check if the process exists using pidof.
    Returns the PID if running, or None if not.
    """
    pid = run_su_command(f"pidof {package_name}")
    if pid and pid.isdigit():
        return pid
    return None

def layer2_state_check(package_name):
    """
    Layer 2: Check the actual application state using dumpsys.
    We look at dumpsys activity to see if the app is crashed or ANR.
    """
    # Check for ANR (Application Not Responding) or Crash dialogs specifically for this package
    # A crash dialog usually appears as an activity or window.
    # We can also check dumpsys activity processes
    
    # 1. Check if the process is marked as crashed/ANR in dumpsys activity processes
    # The output of dumpsys activity processes contains lines like:
    # "ProcessRecord{... com.roblox.client/u0a123}"
    # and "hasCrashDialog=true" or "notResponding=true"
    
    dumpsys_output = run_su_command(f"dumpsys activity processes | grep -A 10 '{package_name}'")
    
    if dumpsys_output:
        if "hasCrashDialog=true" in dumpsys_output or "crashing=true" in dumpsys_output:
            return "CRASHED"
        if "notResponding=true" in dumpsys_output or "anr=" in dumpsys_output:
            return "ANR"
            
    # 2. Check window policy for crash dialogs (com.android.systemui or android showing an error)
    # Sometimes Android shows "Roblox keeps stopping"
    # We can search the current windows to see if a crash dialog is focused.
    focused_window = run_su_command("dumpsys window displays | grep 'mCurrentFocus'")
    if "Application Error" in focused_window or "Crash" in focused_window:
        # If a crash dialog is the focus, we can assume the foreground app crashed.
        # This is a bit generic, but if the target package was supposed to be running, it's a good indicator.
        return "CRASH_DIALOG_FOCUSED"
        
    return "HEALTHY"

def main():
    if len(sys.argv) < 2:
        print("STATUS:ERROR_NO_PACKAGE")
        sys.exit(1)
        
    package_name = sys.argv[1]
    
    # Layer 1
    pid = layer1_process_check(package_name)
    
    if not pid:
        # The process doesn't even exist
        print("STATUS:NOT_RUNNING")
        sys.exit(0)
        
    # Layer 2
    state = layer2_state_check(package_name)
    
    if state == "HEALTHY":
        print("STATUS:RUNNING")
    else:
        print(f"STATUS:CRASHED_STATE_{state}")

if __name__ == "__main__":
    main()
