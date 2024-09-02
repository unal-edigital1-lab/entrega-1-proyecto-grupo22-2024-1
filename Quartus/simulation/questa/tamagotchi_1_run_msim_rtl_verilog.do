transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+/home/bonbartlessby/Documentos/Github/entrega-1-proyecto-grupo22-2024-1/Quartus/db {/home/bonbartlessby/Documentos/Github/entrega-1-proyecto-grupo22-2024-1/Quartus/db/LightSensor.v}

vlog -vlog01compat -work work +incdir+/home/bonbartlessby/Documentos/Github/entrega-1-proyecto-grupo22-2024-1/Quartus/db {/home/bonbartlessby/Documentos/Github/entrega-1-proyecto-grupo22-2024-1/Quartus/db/LightSensor_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  LightSensor_tb

add wave *
view structure
view signals
run -all
