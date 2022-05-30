import time
from bs4 import BeautifulSoup

def findFunList(soup : BeautifulSoup):
    for h3 in soup.find_all("h3"):
        if h3.text == "API Function List":
            return h3
        

def main():

    start = time.process_time()
    
    with open("docs/demos/api.html", "r") as html:
        soup = BeautifulSoup(html, 'html.parser')

    funList = findFunList(soup)
    print(funList.text)
    
    end = time.process_time()
    print(end - start) 


if __name__ == "__main__":
    main()
