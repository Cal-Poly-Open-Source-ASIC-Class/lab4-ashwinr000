
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import (
    RisingEdge, FallingEdge,
    Timer
)

async def generate_r_clk(dut):
    for cycle in range(100):
        dut.r_clk.value = 0
        await Timer(7, units="ns")
        dut.r_clk.value = 1
        await Timer(7, units="ns")

async def generate_w_clk(dut):
    for cycle in range(100):
        dut.w_clk.value = 0
        await Timer(11, units="ns")
        dut.w_clk.value = 1
        await Timer(11, units="ns")

async def w_task(dut):
    await FallingEdge(dut.w_clk)
    dut.w_en.value = 1
    dut.w_data.value = 0
    await RisingEdge(dut.w_clk)

    for i in range(1, 11):
        await FallingEdge(dut.w_clk)
        dut.w_data.value = i
        await RisingEdge(dut.w_clk)

    await FallingEdge(dut.w_clk)
    dut.w_en.value = 0
    await RisingEdge(dut.w_clk)

async def r_task(dut):
    await FallingEdge(dut.r_clk)
    dut.r_en.value = 1
    await RisingEdge(dut.r_clk)

    await Timer(300, units="ns")

    await FallingEdge(dut.r_clk)
    dut.r_en.value = 0
    await RisingEdge(dut.r_clk)

async def w_task_full(dut):
    await FallingEdge(dut.w_clk)
    dut.w_en.value = 1
    dut.w_data.value = 0
    await RisingEdge(dut.w_clk)

    for i in range(1, 32):
        await FallingEdge(dut.w_clk)
        dut.w_data.value = i
        await RisingEdge(dut.w_clk)

    await FallingEdge(dut.w_clk)
    dut.w_en.value = 0
    await RisingEdge(dut.w_clk)

async def r_task_empty(dut):
    await FallingEdge(dut.r_clk)
    dut.r_en.value = 1
    await RisingEdge(dut.r_clk)

    for i in range(32):
        await FallingEdge(dut.r_clk)
        await RisingEdge(dut.r_clk)

    await FallingEdge(dut.r_clk)
    dut.r_en.value = 0
    await RisingEdge(dut.r_clk)
    

@cocotb.test()
async def template_test(dut):
    
    cocotb.start_soon(Clock(dut.r_clk, 13, units='ns').start())
    cocotb.start_soon(Clock(dut.w_clk, 7, units='ns').start())
    #await cocotb.start(generate_r_clk(dut))
    #await cocotb.start(generate_w_clk(dut))

    dut.rst.value = 0
    await Timer(10, units="ns")
    dut.rst.value = 1
    #await RisingEdge(dut.clk)
    await Timer(10, units="ns")
    dut.rst.value = 0
    dut.w_en.value = 0
    dut.r_en.value = 0

    #task1 = cocotb.start_soon(w_task_full(dut))
    #await task1
    #task2 = cocotb.start_soon(r_task_empty(dut))
    #await task2

    task1 = cocotb.start_soon(w_task(dut))
    task2 = cocotb.start_soon(r_task(dut))
    await task1
    await task2

    #await Timer(30, units="ns")

    #await cocotb.start(r_task(dut))

    #await Timer(300, units="ns")

    


