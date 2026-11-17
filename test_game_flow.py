import requests
import json

BASE_URL = "http://localhost:8011"

def test_flow():
    print("Testing root...")
    r = requests.get(f"{BASE_URL}/")
    print("Root:", r.status_code, r.json())
    assert r.status_code == 200

    print("\nTesting plain user login...")
    r = requests.post(f"{BASE_URL}/user/login", json={"userId": "12345678", "deviceId": "device123"})
    print("User Login Status:", r.status_code)
    try:
        data = r.json()
        print("User Login JSON Response keys:", list(data.keys()))
        print("User ID in response:", data.get("user", {}).get("id"))
        print("AuthToken:", data.get("authToken"))
        assert data.get("status") == 0
    except Exception as e:
        print("Failed to parse JSON:", e, r.text)
        raise e

    print("\nTesting login with query parameters (?userId=9988776655)...")
    r = requests.get(f"{BASE_URL}/a/b/cde/user/login", params={"userId": "9988776655"})
    print("Query Param Login Status:", r.status_code)
    data = r.json()
    print("User ID echoed in response:", data.get("user", {}).get("id"))
    assert data.get("user", {}).get("id") == "9988776655"

    print("\nAll integration simulation tests passed successfully!")

if __name__ == "__main__":
    test_flow()
