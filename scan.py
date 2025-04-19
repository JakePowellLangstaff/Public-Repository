import dns.resolver
import socket
import nmap3
from pythonping import ping

# DNS Resolution Function (unchanged)
def resolve_dns(domain):
    try:
        result = dns.resolver.resolve(domain, 'A')
        return '\n'.join([f'IP: {ipval.to_text()}' for ipval in result])
    except Exception as e:
        return f"Error resolving DNS: {e}"

# Nmap Setup (unchanged)
nmap = nmap3.Nmap()

# ✅ Updated: Added optional parameters to control what scans to perform
def perform_full_scan(ip_addr, scan_ping=False, scan_tcp=False, scan_os=False, scan_vuln=False):
    results = {
        "ping": None,
        "os_info": None,
        "open_ports": None,
        "vulnerabilities": None
    }

    # ✅ Optional: validate and resolve hostnames to IP
    try:
        socket.inet_aton(ip_addr)
    except socket.error:
        try:
            ip_addr = socket.gethostbyname(ip_addr)
        except socket.gaierror:
            results["ping"] = f"Error: Unable to resolve hostname '{ip_addr}'"
            return results

    # ✅ Only do ping scan if user selected it
    if scan_ping:
        try:
            ping_result = ping(ip_addr, count=4)
            # Format the ping results as a single string
            results["ping"] = [f"Ping to {ip_addr}: {str(ping_result)}"]
        except Exception as e:
            results["ping"] = [f"Error pinging {ip_addr}: {str(e)}"]

    # ✅ Only do OS detection if selected
    if scan_os: # tested
        try:
            os_results = nmap.nmap_os_detection(ip_addr)
            # Get the first host's OS matches
            host_os_results = next(iter(os_results.values())) if os_results else {}
            results["os_info"] = host_os_results.get("osmatch", [])
        except Exception as e:
            results["os_info"] = f"Error scanning with Nmap OS detection: {e}"

    # ✅ Only do TCP/Port Scan if selected
    if scan_tcp:
        try:
            open_ports_results = nmap.nmap_version_detection(ip_addr)
          #  print("Full Open Ports Response:", open_ports_results)  # Debugging
            host_results = open_ports_results.get(ip_addr, {})
           # print("Host Results:", host_results)  # Debugging
            results["open_ports"] = host_results.get("ports", [])
           # print("Extracted Open Ports:", results["open_ports"])  # Debugging
        except Exception as e:
            results["open_ports"] = f"Error scanning ports with Nmap: {e}"
          #  print(f"[ERROR] TCP Scan: {e}")  # Debugging




          #  open_ports_results = nmap.nmap_version_detection(ip_addr) # Must be root
          #  results["open_ports"] = open_ports_results.get("ports", [])
           # open_ports_info = open_ports_results.get(ip_addr, {}).get("ports", [])
           # print("Full Open Ports Response:", open_ports_results)



      # except Exception as e:
           
          #  results["open_ports"] = host_results.get("ports", [])

           #  results["open_ports"] = f"Error scanning ports with Nmap: {e}"

    # ✅ Only do Vulnerability scan if selected
    if scan_vuln:
        try:
            vuln_results = nmap.nmap_version_detection(ip_addr, args="--script vulners --script-args mincvss+5.0")
            vuln_info = []

            for port in vuln_results.get("ports", []):
                port_id = port.get("portid")
                service = port.get("service", {})
                service_name = service.get("name", "Unknown")
                product = service.get("product", "Unknown")

                port_vulns = []
                if "scripts" in port and "vulners" in port["scripts"]:
                    for vuln in port["scripts"]["vulners"]:
                        port_vulns.append({
                            "id": vuln["id"],
                            "cvss": vuln["cvss"],
                            "href": vuln["href"]
                        })

                vuln_info.append({
                    "port": port_id,
                    "service": service_name,
                    "product": product,
                    "vulnerabilities": port_vulns
                })

            results["vulnerabilities"] = vuln_info
        except Exception as e:
            results["vulnerabilities"] = f"Error scanning vulnerabilities with Nmap: {e}"

    return results

