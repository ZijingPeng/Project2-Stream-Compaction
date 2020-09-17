#include <cstdio>
#include "cpu.h"

#include "common.h"

namespace StreamCompaction {
    namespace CPU {
        using StreamCompaction::Common::PerformanceTimer;
        PerformanceTimer& timer()
        {
            static PerformanceTimer timer;
            return timer;
        }

        /**
         * CPU scan (prefix sum).
         * For performance analysis, this is supposed to be a simple for loop.
         * (Optional) For better understanding before starting moving to GPU, you can simulate your GPU scan in this function first.
         */
        void scan(int n, int *odata, const int *idata) {
            //timer().startCpuTimer();
            odata[0] = 0;
            for (int i = 0; i < n - 1; i++) {
                odata[i + 1] = odata[i] + idata[i];
            }
            //timer().endCpuTimer();
        }

        /**
         * CPU stream compaction without using the scan function.
         *
         * @returns the number of elements remaining after compaction.
         */
        int compactWithoutScan(int n, int *odata, const int *idata) {
            timer().startCpuTimer();
            int o = 0;
            for (int i = 0; i < n; i++) {
                if (idata[i]) {
                    odata[o++] = idata[i];
                }
            }
            timer().endCpuTimer();
            return o - 1;
        }

        /**
         * CPU stream compaction using scan and scatter, like the parallel version.
         *
         * @returns the number of elements remaining after compaction.
         */
        int compactWithScan(int n, int *odata, const int *idata) {
            timer().startCpuTimer();
            int* map = new int[n];
            for (int i = 0; i < n; i++) {
                map[i] = idata[i] ? 1 : 0;
            }
            int* sout = new int[n];
            scan(n, sout, map);
            int o = 0;
            for (int i = 0; i < n; i++) {
                if (map[i] != 0) {
                    odata[sout[i]] = idata[i];
                    o++;
                }
            }
            timer().endCpuTimer();
            delete[] map;
            delete[] sout;
            return o - 1;
        }
    }
}
