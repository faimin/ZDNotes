
# Jenkins自用脚本

### 定期清理Xcode缓存

```sh
#!/usr/bin/env bash -l

#H 4 * * *  轮询执行

path1="${HOME}/Library/Developer/Xcode/DerivedData"
for i in $(ls ${path1} | grep '{{ Project }}'); do 
	#获取DerivedData目录下每个文件夹的大小(以M为单位)
    complete_path="${path1}/${i}"
	file_size=$(du -sm ${complete_path} | awk '{print $1}')
    echo "文件Size = ${file_size}"
    #大于5G的移除
	if (( ${file_size} >= 5000 )); then
    	echo "缓存超过限制，删掉  ${i}"
        rm -rf ${complete_path}
	fi
done

path2="${HOME}/Documents/{{ Path }}"
for i in $(ls ${path2}); do 
	file_path="${path2}/${i}/DerivedData"
	file_size=$(du -sm ${file_path} | awk '{print $1}')
    echo "文件Size = ${file_size}"
	if (( ${file_size} >= 3000 )); then
    	echo "缓存超过限制，删掉  ${file_path}"
        rm -rf ${file_path}
	fi
done
```