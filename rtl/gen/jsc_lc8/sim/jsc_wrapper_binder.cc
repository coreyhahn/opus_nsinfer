#include <cstddef>
#include "binder_util.hh"
#include "Vjsc_wrapper.h"

struct jsc_wrapper_config {
    static const size_t N_inp = 16;
    static const size_t N_out = 5;
    static const size_t max_inp_bw = 14;
    static const size_t max_out_bw = 17;
    static const size_t II = 1;
    static const size_t latency = 4;
    typedef Vjsc_wrapper dut_t;
};

extern "C" {
bool openmp_enabled() {
    return _openmp;
}

void inference(int32_t *c_inp, int32_t *c_out, size_t n_samples, size_t n_threads) {
    batch_inference<jsc_wrapper_config>(c_inp, c_out, n_samples, n_threads);
}
}
