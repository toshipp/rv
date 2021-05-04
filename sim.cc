#include <fcntl.h>
#include <getopt.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <verilated.h>

#include <iostream>
#include <map>
#include <memory>
#include <string>

#include "Vsim.h"

static const std::uint32_t start_address = 0x80000000;

static const std::uint32_t tohost_address = 0x80001000;

using MemoryMap = std::map<std::uint32_t, std::uint32_t>;

MemoryMap& getMemoryInstance() {
    static MemoryMap mem;

    return mem;
}

extern "C" int memory_read(int addr) {
    return getMemoryInstance()[addr];
}

extern "C" void memory_write(int addr, int data, int mask) {
    auto& m = getMemoryInstance()[addr];
    m = (m & ~mask) | (data & mask);
}

struct sim_opt {
    int interrupt_on_after;
    int interrupt_off_after;
    int timeout;
};

int simulate(int argc, char** argv, const sim_opt& opt) {
    Verilated::commandArgs(argc, argv);
    auto top = std::make_unique<Vsim>();

    unsigned int cycle = 0;
    const unsigned int reset_cycle = 2;

    top->reset = 1;
    top->clk = 0;

    while (!Verilated::gotFinish()) {
        if (opt.timeout != -1 && cycle > opt.timeout) {
            std::cerr << "timeout" << std::endl;
            return 1;
        }

        if (cycle > reset_cycle) {
            top->reset = 0;
        }

        if (opt.interrupt_on_after != -1 && cycle > opt.interrupt_on_after) {
            top->external_interrupt = 1;
        }
        if (opt.interrupt_off_after != -1 && cycle > opt.interrupt_off_after) {
            top->external_interrupt = 0;
        }

        top->eval();

        if (top->clk > 0) {
            std::cerr << "#eval" << std::endl;
            std::cerr << "pc: " << std::hex << top->debug_pc << std::endl;
            std::cerr << "inst: " << std::hex << top->debug_instruction
                      << std::endl;
            std::cerr << "state: " << std::dec
                      << static_cast<unsigned int>(top->debug_state)
                      << std::endl;
            std::cerr << "in1: " << std::hex
                      << static_cast<unsigned int>(top->debug_in1) << std::endl;
            std::cerr << "in2: " << std::hex
                      << static_cast<unsigned int>(top->debug_in2) << std::endl;
            std::cerr << "result: " << std::hex
                      << static_cast<unsigned int>(top->debug_result)
                      << std::endl;
        }

        {
            int fail_test = getMemoryInstance()[tohost_address];
            if (fail_test == 1) {
                std::cerr << "pass" << std::endl;
                return 0;
            } else if (fail_test > 1) {
                std::cerr << "fail: " << std::dec << (fail_test >> 1)
                          << std::endl;
                return 1;
            }
        }

        if (top->clk > 0) {
            ++cycle;
        }

        top->clk = !top->clk;
    }
    top->final();

    return 0;
}

void load_instructions(const char* name) {
    int fd = ::open(name, O_RDONLY);
    if (fd == -1) {
        throw std::runtime_error("failed to open");
    }

    std::uint32_t data;
    std::uint32_t addr = start_address;

    while (true) {
        int ret = ::read(fd, &data, sizeof(data));
        if (ret == -1) {
            throw std::runtime_error("failed to read");
        }
        if (ret == 0) {
            break;
        }
        if (ret != 4) {
            throw std::runtime_error("failed to 4 byte read");
        }

        getMemoryInstance()[addr] = data;
        addr += 4;
    }
    ::close(fd);
}

int main(int argc, char** argv, char** env) {
    ::option long_options[] = {
        {"interrupt-on-after", required_argument, nullptr, 1},
        {"interrupt-off-after", required_argument, nullptr, 2},
        {"timeout", required_argument, nullptr, 3},
        {nullptr, 0, nullptr, 0},
    };

    sim_opt opt{-1, -1, -1};

    for (;;) {
        int c = ::getopt_long(argc, argv, "", long_options, nullptr);
        if (c == -1) {
            break;
        }

        try {
            switch (c) {
                case 1:
                    opt.interrupt_on_after = std::stoi(::optarg);
                    break;
                case 2:
                    opt.interrupt_off_after = std::stoi(::optarg);
                    break;
                case 3:
                    opt.timeout = std::stoi(::optarg);
                    break;
                default:
                    std::cerr << "unknown option" << std::endl;
                    return 1;
            }
        } catch (...) {
            std::cerr << "invalid argument" << std::endl;
            return 1;
        }
    }

    if (::optind == argc) {
        std::cerr << "no executable provided" << std::endl;
        return 1;
    }
    if (::optind < argc - 1) {
        std::cerr << "too many argument" << std::endl;
        return 1;
    }

    try {
        load_instructions(argv[::optind]);
        return simulate(argc, argv, opt);
    } catch (const std::runtime_error& e) {
        std::cerr << e.what() << std::endl;
        return 1;
    }
}
