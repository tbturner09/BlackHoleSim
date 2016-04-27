# Define options
set	val(chan)	Channel/WirelessChannel;#Channel Type
set	val(prop)	Propagation/TwoRayGround;# radio-propagation model
set	val(netif)	Phy/WirelessPhy;# network interface type
set	val(mac)	Mac/802_11;# MAC type
set	val(ifq)	Queue/DropTail/PriQueue;# interface queue type
set	val(ll)	LL;# link layer type
set	val(ant)	Antenna/OmniAntenna;# antenna model
set	val(ifqlen)	150;# max packet in ifq
set	val(nn)	10;# total number of mobilenodes
set	val(nnaodv)	9;# number of AODV mobilenodes
set	val(rp)	AODV;# routing protocol
set	val(bp)	blackholeAODV;#blackholeAODV protocol
set	val(x)	750;# X dimension of topography
set	val(y)	750;# Y dimension of topography
set	val(cstop)	951;# time of connections end
set	val(stop)	1000;# time of simulation end
set	val(cp)	"scenarios/scen1";#Connection Pattern
set	val(cc)	"scenarios/cbr-10-test";#CBR Connections




# Initialize Global Variables
set ns_	[new Simulator]

$ns_ use-newtrace
set tracefd	[open sim1forNormal.tr w]
$ns_ trace-all $tracefd

set namtrace	[open sim1forNormal.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object
set topo	[new Topography]
$topo load_flatgrid $val(x) $val(y)

# Create God
create-god $val(nn)

# Create channel #1 and #2
set chan_1_ [new $val(chan)]
set chan_2_ [new $val(chan)]

# configure node, please note the change below.
$ns_ node-config	-adhocRouting $val(rp) \
			-llType $val(ll) \
			-macType $val(mac) \
			-ifqType $val(ifq) \
			-ifqLen $val(ifqlen) \
			-antType $val(ant) \
			-propType $val(prop) \
			-phyType $val(netif) \
			-topoInstance $topo \
			-agentTrace ON \
			-routerTrace ON \
			-macTrace ON \
			-movementTrace ON \
			-channel $chan_1_

# Creating mobile AODV nodes for simulation
puts "Creating nodes..."
for {set i 0} {$i <= $val(nnaodv)} {incr i} {
puts "This node is a regular node: $i"
	set node_($i) [$ns_ node]
	$node_($i) random-motion 0; #disable random motion
}

# Adding connection pattern which is created using setdest, parameters shown below
# ./setdest -n 20 -p 1.0 -M 20.0 -t 500 -x 750 -y 750 > scen1forAODV-n20-t500-x750-y750

puts "Loading random connection pattern..."
set god_ [God instance]
source $val(cp)

################### CBRGEN GENERATE SAME CODE #############################
# set j 0
# 
# for {set i 0} {$i < 18} {incr i} {
#      #Create a UDP and NULL agents, then attach them to the appropriate nodes
#	set udp_($j) [new Agent/UDP]
#	$ns_ attach-agent $node_($i) $udp_($j)
#	set null_($j) [new Agent/Null]
#	$ns_ attach-agent $node_([expr $i + 1]) $null_($j)
#      #Attach CBR application;
#	set cbr_($j) [new Application/Traffic/CBR]
#	puts "cbr_($j) has been created over udp_($j)"
#	$cbr_($j) set packet_size_ 512
#	$cbr_($j) set interval_ 1
#	$cbr_($j) set rate_ 10kb
#	$cbr_($j) set random_ false
#	$cbr_($j) attach-agent $udp_($j)
#	$ns_ connect $udp_($j) $null_($j)
#	puts "udp_($j) and null_($j) agents has been connected each other"
#	$ns_ at 1.0 "$cbr_($j) start"
#	set j [expr $j + 1]
#	set i [expr $i + 1]
# }
############################################################################

# CBR Connections generated by cbrgen
source $val(cc)


# Define initial node position
for {set i 0} {$i < $val(nn) } {incr i} {
	$ns_ initial_node_pos $node_($i) 30
}

# CBR connections stops
for {set i 0} {$i < 7 } {incr i} {
	$ns_ at $val(cstop) "$cbr_($i) stop"
}

# Tell all nodes when the simulation ends
	for {set i 0} {$i < $val(nn) } {incr i} {
$ns_ at $val(stop).000000001 "$node_($i) reset";
}

# Ending nam and simulation
$ns_ at $val(stop) "finish"
$ns_ at $val(stop).0 "$ns_ trace-annotate \"Simulation has ended\""
$ns_ at $val(stop).00000001 "puts \"NS EXITING...\" ; $ns_ halt"

proc finish {} {
	global ns_ tracefd namtrace
	$ns_ flush-trace
	close $tracefd
	close $namtrace
	#exec nam sim1forBlackHole.nam &
	exit 0
}

puts "Starting Simulation..."
$ns_ run


