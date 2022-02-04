import requests as reeeeeee
from colorama import Fore

sitemap = []
disallow = []

def banner():
    print("""
       _ _             _         
     _| |_|___ ___ ___|_|___ ___ 
    | . | |  _|_ -|   | | . | -_|
    |___|_|_| |___|_|_|_|  _|___|
                        |_|      
    Author: Gr1mmie
    """)

def fetch(schema:str, site:str) -> str:
    try:
        reeeeeee.get(f"{schema}{site}/robots.txt")
    except Exception:
        print(Fore.RED, "[-] URL failed to resolve. Exitting...", Fore.RESET)
        quit()

    return (reeeeeee.get(f"{schema}{site}/robots.txt").text)

def parse(robots_content:str, disallow:list, sitemap:list):
    for line in robots_content.split('\n'):
        if ("Disallow" in line):
            disallow.append(line.split(": ")[1])
        if("Sitemap" in line):
            sitemap.append(line.split(' ')[1])

def arrPrint(sitemap:list, disallow:list):
    print("[+] Sitemap:")
    for sm in sitemap:
        print(Fore.GREEN, f"{sm}", Fore.RESET)

    print("\n[+] Dirs fetched:")
    for dir in disallow:
        print(Fore.GREEN, f"{schema}{site}{dir}", Fore.RESET)

try:
    banner()

    site = input(" Enter a site: ")
    schema = "http://"

    print()

    robots_content = fetch(schema, site)
    parse(robots_content, disallow, sitemap)
    arrPrint(sitemap, disallow)
except KeyboardInterrupt:
    print(Fore.RED, "[-] Keyboard interrupt detected. Exitting...", Fore.RESET)
