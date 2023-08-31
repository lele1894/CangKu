#!/bin/bash
timeout_sec=5 # 设置超时时间
# 定义待测试的 IP 和别名关联列表
declare -A ip_alias=(
  ["jg1"]="0.0.0.0"
  ["jg2"]="0.0.0.0"
  ["jg3"]="0.0.0.0"
  ["jg4"]="0.0.0.0"
  ["vps"]="26:40:0:24:f6:5f:bc:f"
)
# 新建一个变量 $OLD_STATUS
OLD_STATUS=""
flag=false
while true; do
	#echo "$NEW_STATUS"
	# 获取当前状态
	NEW_STATUS=""
    # 判断是否在直播中
    is_live=$(curl -s 'https://api.live.bilibili.com/room/v1/Room/get_info?id=32269' | jq '.data.live_status')
    if [[ "${is_live}" == "1" ]]; then
        echo "B站正常"
		NEW_STATUS+="B站正常/"
        #curl -d "text=直播中！" 'http://miaotixing.com/trigger?id=-------'
    elif [[ "${is_live}" != "1" ]]; then
        echo "B站中断"
		NEW_STATUS+="B站中断/"
        #curl -d "text=B站直播中断了！" 'http://miaotixing.com/trigger?id=-------'
    fi
<<EOF
  if curl -s "https://www.huya.com/26790602" | grep -q "上次开播"; then
    echo "虎牙关播"
	NEW_STATUS+="虎牙关播/"
    #curl -d "text=虎牙关播" http://miaotixing.com/trigger?id=-------
  else
    echo "虎牙正常"
	NEW_STATUS+="虎牙正常/"
  fi
EOF

  if curl -s "https://open.douyucdn.cn/api/RoomApi/room/292098" | grep -q '"room_status":"1"'; then
    echo "斗鱼正常"
	NEW_STATUS+="斗鱼正常/"
  else
    echo "斗鱼关播"
	NEW_STATUS+="斗鱼关播/"
    #curl -d "text=斗鱼关播/" http://miaotixing.com/trigger?id=-------
  fi
  
	url="https://ly.lejin.repl.co"
	
	response=$(curl -s -o /dev/null -w "%{http_code}" $url)
	
	if [ $response -eq 200 ]; then
	echo "留言正常"
	NEW_STATUS+="留言正常/"
	else
	echo "留言崩溃"
	NEW_STATUS+="留言崩溃/"
	fi
	
echo "手机-http://[$(curl -s ipv6.ip.sb)]:5244/"
#NEW_STATUS+="手机-http://[$(curl -s ipv6.ip.sb)]:5244/"
# 循环测试每个IP地址并输出结果
for alias in "${!ip_alias[@]}"
do
  ip_address=${ip_alias[$alias]}
  # 发送 Ping 请求并获取结果
  ping_result=$(ping -c 1 -w ${timeout_sec} ${ip_address})
  # 检查 Ping 结果并输出相应信息
  if [ $? -eq 0 ] && echo ${ping_result} | grep -q "1 received"; then
    echo "${alias} (${ip_address})正常"
	NEW_STATUS+="${alias} (${ip_address})正常/"
  else
    echo "${alias} (${ip_address})断连"
	NEW_STATUS+="${alias} (${ip_address})断连/"
	#curl -d "text=${alias} (${ip_address})断连" http://miaotixing.com/trigger?id=-------
  fi
done
<<EOF
  if curl --output /dev/null --silent --head --fail "https://html.lejin.repl.co/"; then
    echo "塞尔达网站正常"
	NEW_STATUS+="塞尔达网站正常/"
  else
    echo "塞尔达网站下线了"
	NEW_STATUS+="塞尔达网站下线了/"
    #curl -d "text=塞尔达网站下线了！" http://miaotixing.com/trigger?id=-------
  fi
  if curl --output /dev/null --silent --head --fail "https://lele1894.tk/"; then
    echo "tk网站正常"
	NEW_STATUS+="tk网站正常/"
  else
    echo "tk网站下线了"
	NEW_STATUS+="tk网站下线了/"
    #curl -d "text=tk网站下线了！" http://miaotixing.com/trigger?id=-------
  fi
EOF

# 对比状态
if [ "$flag" = true ]; then 
	if [ "$NEW_STATUS" != "$OLD_STATUS" ]; then
    # 如果状态有变化，更新旧状态，并发送通知
    OLD_STATUS="$NEW_STATUS"
		#发送通知
		if [ "$NEW_STATUS" != "" ]; then
			#如果存在状态数据，发送到指定邮箱或 HTTP 请求平台
			echo "状态有变化，发送通知"
			curl -d "text=$NEW_STATUS" http://miaotixing.com/trigger?id=-------
		else
			# 如果状态没有变化，不发送通知
			echo "状态没有变化，不发送通知"
		fi
	fi
else
echo "第一次把结果先存入"
OLD_STATUS="$NEW_STATUS"
flag=true
fi
sleep 600
done
