#!/bin/awk -f
BEGIN{


}
{
  event = $1
  time = 0 + $3 # Make sure that "time" has a numeric type.
  pkt_size = 0 + $37
  level = $19


  if (level == "MAC" && event == "s" && $35 == "cbr") {
    sent++
    if (!startTime || (time < startTime)) {
      startTime = time
    }
  }

  if (level == "MAC" && event == "r" && $35 == "cbr") {
    receive++
    if (time > stopTime) {
      stopTime = time
    }
    recvdSize += pkt_size
    
  }
  if(event == "d" && $19 == "RTR" && $21 == "LOOP"){
    pkt_drop++
    recvdSize -= pkt_size
    
  }
  
}

   
END {

  
  netpacketsdropped = (receive - pkt_drop)
  printf("start time = %f, stopTime = %f\n", startTime, stopTime)
  printf("sent packets\t %d\n",sent)
  printf("received packets %d\n",receive)
  printf("packets recived and dropped by blackhole node = %d\n",pkt_drop)
  printf("Net packets recived by non-malious nodes = %d\n", netpacketsdropped)
  PDR = (netpacketsdropped/sent)*100
  printf("PDR = %f\n",PDR)
  printf("Average Throughput[kbps] = %.2f\tStartTime=%.2f\tStopTime = %.2f\n", (recvdSize/(stopTime-startTime))*(8/1000),startTime,stopTime)

}

