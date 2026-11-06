#include <cstddef>
#include "binder_util.hh"
#include "Vqec_d5_wrapper.h"

struct qec_d5_wrapper_config {
    static const size_t N_inp = 120;
    static const size_t N_out = 1;
    static const size_t max_inp_bw = 5;
    static const size_t max_out_bw = 22;
    static const size_t II = 1;
    static const size_t latency = 13;
    typedef Vqec_d5_wrapper dut_t;
};

extern "C" {
bool openmp_enabled() {
    return _openmp;
}

void inference(int32_t *c_inp, int32_t *c_out, size_t n_samples, size_t n_threads) {
    batch_inference<qec_d5_wrapper_config>(c_inp, c_out, n_samples, n_threads);
}
}
