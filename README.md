
# URL MINNER
Scan Android APK files for endpoints and extract them into a text file for further analysis.

![image](https://user-images.githubusercontent.com/34772838/228215410-9c732d32-9eb5-4b1b-b937-adec85e157f9.png)
![image](https://user-images.githubusercontent.com/34772838/228215505-d41827df-c93c-4a3d-af52-965b15bc0630.png)


# Requirements
```
apktool
pv

sudo apt-get install apktool pv

```

## Usage


```
./URL.sh <apk-file>


Replace <apk-file> with the path to the APK file you want to scan.


The script will decompile the APK file, extract the HTTP/HTTPS endpoints, and save them to a file named endpoints.txt in the same directory as the APK file.



