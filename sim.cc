#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include <memory>
#include <iostream>
#include <map>

#include <verilated.h>

#include "Vsim.h"

static const std::uint32_t INST_ECALL = 0x73;

static const std::uint32_t start_address = 0x80000000;

using MemoryMap = std::map<std::uint32_t, std::uint32_t>;

MemoryMap& getMemoryInstance() {
    static MemoryMap mem;

    return mem;
}

extern "C" int memory_read(int addr) {
    auto data = getMemoryInstance()[addr];
    return data;
}

extern "C" void memory_write(int addr, int data, int mask) {
    auto& m = getMemoryInstance()[addr];
    m = (m & ~mask) | (data & mask);
}

int simulate(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    auto top = std::make_unique<Vsim>();

    unsigned int reset_clocks = 2;

    top->reset = 1;
    top->clk = 0;

    while (!Verilated::gotFinish()) {
        if(top->clk > 0) {
            if(reset_clocks > 0) {
                --reset_clocks;
            } else {
                top->reset = 0;
            }
        }

        top->eval();

        if(top->clk > 0) {
            std::cerr << "#eval" << std::endl;
            std::cerr << "pc: " << std::hex << top->debug_pc << std::endl;
            std::cerr << "inst: " << std::hex << top->debug_instruction << std::endl;
            std::cerr << "state: " << std::dec << static_cast<unsigned int>(top->debug_state) << std::endl;
            std::cerr << "in1: " << std::hex << static_cast<unsigned int>(top->debug_in1) << std::endl;
            std::cerr << "in2: " << std::hex << static_cast<unsigned int>(top->debug_in2) << std::endl;
            std::cerr << "result: " << std::hex << static_cast<unsigned int>(top->debug_result) << std::endl;
        }

        if(top->trap) {
            std::cerr << "trap" << std::endl;

            if(top->debug_instruction == INST_ECALL){
                svSetScope(svGetScopeFromName("TOP.sim.core.data_path.register_file"));
                int a0, a7;
                read_register(10, &a0);
                read_register(17, &a7);
                if(a7 == 93 && a0 == 0) {
                    std::cerr << "pass" << std::endl;
                    return 0;
                } else {
                    std::cerr << "fail: " << std::dec << (a0 >> 1) << std::endl;
                    return 1;
                }
            }

            return 1;
        }

        top->clk = !top->clk;
    }
    top->final();

    return 0;
}

void load_instructions(const char* name) {
    int fd = ::open(name, O_RDONLY);
    if(fd == -1) {
        throw std::runtime_error("failed to open");
    }

    std::uint32_t data;
    std::uint32_t addr = start_address;

    while(true) {
        int ret = ::read(fd, &data, sizeof(data));
        if(ret == -1) {
            throw std::runtime_error("failed to read");
        }
        if(ret == 0) {
            break;
        }
        if(ret != 4) {
            throw std::runtime_error("failed to 4 byte read");
        }

        getMemoryInstance()[addr] = data;
        addr += 4;
    }
    ::close(fd);
}




int main(int argc, char** argv, char** env) {
    if(argc < 2) {
        std::cerr << "no executable provided" << std::endl;
        return 1;
    }

    try {
        load_instructions(argv[1]);
        return simulate(argc, argv);
    } catch(const std::runtime_error& e) {
        std::cerr << e.what() << std::endl;
        return 1;
    }
}
