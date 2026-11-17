from mitmproxy import http

def request(flow: http.HTTPFlow) -> None:
    target_domains = [
        "dci-p.socialpointgames.com",
        "api.zynga.com",
        "external.api.zynga.com",
        "internal.api.zynga.com"
    ]
    
    if any(domain in flow.request.pretty_host for domain in target_domains):
        original_url = flow.request.url
        flow.request.host = "127.0.0.1"
        flow.request.port = 8000
        flow.request.scheme = "http"
        print(f"[Proxy Redirect] {original_url} -> {flow.request.url}")
