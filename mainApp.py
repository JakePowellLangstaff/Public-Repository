from flask import Flask, render_template, request
from scan import perform_full_scan
import socket

app = Flask(__name__, template_folder='html_files')

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/process", methods=["POST"])
def process_scan():
    ip_or_domain = request.form["ip_address"]

    # Checkbox values
    scan_ping = "scan_ping" in request.form
    scan_tcp = "scan_tcp" in request.form
    scan_os = "scan_os" in request.form
    scan_vuln = "scan_vuln" in request.form
    scan_dns = "scan_dns" in request.form

    dns_data = None
    hostname = None

    if scan_dns:
        try:
            resolved = socket.gethostbyname_ex(ip_or_domain)
            dns_data = ', '.join(resolved[2])
            hostname = resolved[0]
        except Exception as e:
            print(f"[ERROR] DNS resolution error: {e}")

    results = None
    if scan_ping or scan_tcp or scan_os or scan_vuln:
        results = perform_full_scan(
            ip_or_domain,
            scan_ping=scan_ping,
            scan_tcp=scan_tcp,
            scan_os=scan_os,
            scan_vuln=scan_vuln
        )
        print("=== SCAN RESULTS ===")
        print(results)  # ✅ Log all the returned data in terminal

    # Extract data safely
    ping_result = results.get("ping") if results else None
    os_info = results.get("os_info") if results else None
    open_ports_info = results.get("open_ports") if results else None
    print("Open Ports Info:", open_ports_info)  # Debugging
    vulnerability_info = results.get("vulnerabilities") if results else None

    return render_template(
        "results.html",
        the_data=ping_result,
        os_data=os_info,
        open_ports_results=open_ports_info,
        vulnerability_data=vulnerability_info,
        dns_data=dns_data,
        hostname=hostname,
        scan_ping=scan_ping,
        scan_tcp=scan_tcp,
        scan_os=scan_os,
        scan_vuln=scan_vuln,
        scan_dns=scan_dns
    )

if __name__ == "__main__":
    app.run(debug=True)
