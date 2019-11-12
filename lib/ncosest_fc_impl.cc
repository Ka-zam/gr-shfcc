/* -*- c++ -*- */
/*                     GNU GENERAL PUBLIC LICENSE
 *                        Version 3, 29 June 2007
 * 
 *  Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
 *  Everyone is permitted to copy and distribute verbatim copies
 *  of this license document, but changing it is not allowed.
 * 
 */

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <gnuradio/io_signature.h>
#include "ncosest_fc_impl.h"

namespace gr {
  namespace shfcc {

    ncosest_fc::sptr
    ncosest_fc::make(float fs, std::vector<float> freqs, float eps_abs, int Neps, int calc_len)
    {
      return gnuradio::get_initial_sptr
        (new ncosest_fc_impl(fs, freqs, eps_abs, Neps, calc_len));
    }

    /*
     * The private constructor
     */
    ncosest_fc_impl::ncosest_fc_impl(float fs, std::vector<float> freqs, float eps_abs, int Neps, int calc_len)
      : gr::sync_decimator("ncosest_fc",
              gr::io_signature::make(1, 1, sizeof(float) ),
              gr::io_signature::make3(3, 3, sizeof(float)*freqs.size(), sizeof(gr_complex)*freqs.size(), sizeof(float) ), 
              calc_len)
    {
      //cout << "Armadillo version: " << arma_version::as_string() << endl;
        d_fs = fs;
        //cout << "Size of freqs " << freqs.size() << endl;
        d_nfreqs = 2*freqs.size();
        d_calc_len = calc_len;
        d_neps = Neps;

        d_freqs.zeros(d_nfreqs);
        for (int i = 0; i < d_freqs.size(); ++i)
        {
            if(i%2==0)
            {
                d_freqs(i) = freqs[i/2];
            }
            else
            {
                d_freqs(i) = -d_freqs(i-1);
            }
            //fprintf(stderr, "d_freqs[%d]: %9.3f\n", i, d_freqs(i) );
        }
        d_eps.set_size(d_neps);
        linspace(d_eps, -eps_abs, eps_abs);
        //cout << "d_eps\n" << d_eps.t();
        init_B_mat();
    }

    /*
     * Our virtual destructor.
     */
    ncosest_fc_impl::~ncosest_fc_impl()
    {
    }

    void 
    ncosest_fc_impl::init_B_mat()
    {
        d_B_mat = cx_fmat(d_calc_len, d_nfreqs*d_neps,fill::zeros);
        /* Preallocate since we know the eps and the dimensions
           B_i = [   exp(1j*0*w0i)     ...    exp(1j*0*wMi) 
                      ...                       ...      
                   exp(1j*(N-1)*w0i)   ...  exp(1j*(N-1)*wMi)]


        */
        cout << "B.shape(): "<<d_B_mat.n_rows << "x" << d_B_mat.n_cols << endl;
        cout << "d_freqs: " << d_freqs.t();
        cout << "Omega(eps(0)): "<<2.f*fdatum::pi*d_freqs.t()*(1.f+d_eps(0))/d_fs<<endl;
        for (int i = 0; i < d_neps; ++i)
        {
          span s;
          epsidx2span(s,i);
          //cx_fmat tmp = d_B_mat(span::all, s );
          //tmp = gr_complex(0.f,1.f)*repmat( 2.f*fdatum::pi*d_freqs*d_eps(i), d_calc_len,1);
          d_B_mat(span::all, s ) = 
           gr_complex(0.f,1.f)*repmat( 2.f*fdatum::pi*d_freqs.t()*(1.f+d_eps(i))/d_fs, d_calc_len,1);
        }


        for (int c = 0; c < d_B_mat.n_cols; ++c)
        {
          for (int r = 0; r < d_B_mat.n_rows; ++r)
          {
            d_B_mat(r,c) = d_B_mat(r,c)*( (float) r );
          }
        }        
        /*
        */
        d_B_mat = exp(d_B_mat);
        real(d_B_mat).eval().save("Br.dat", raw_ascii);
        imag(d_B_mat).eval().save("Bi.dat", raw_ascii);
        d_B_mat(span::all,span(0,3)).print("d_B_mat=");
        return;
    }

    void 
    ncosest_fc_impl::epsidx2span(span &s, const int idx)
    {
        s = span(idx*d_nfreqs,(idx+1)*d_nfreqs-1);
        return;
    }

    void
    ncosest_fc_impl::linspace(fcolvec &v, const float min_val, const float max_val)
    {
      int N = v.size();
      //cout << "N: " << N << endl;
      if (N==1) { v(0) = 0.5*(max_val+min_val); return;}
      if (N==2) { v(0) = min_val; v(1) = max_val; return;}
        double step = (max_val-min_val)/(N-1);
        v(0) = min_val;
        for (int i = 1; i < v.size(); ++i)
        {
            v(i) = v(i-1) + step;
        }
        return;
    }

    float
    ncosest_fc_impl::argmax_interp_p(const fcolvec &x, const fcolvec &y)
    {
        /*
        Return the critical argument xc minimizing or maximizing y[x]
        */
        assert(x.n_rows == y.n_rows && x.n_rows > 2);
        uint32_t idx = y.index_max();
        //cout << "idx_max: " << idx << endl;
        if (idx == 0)        { return x(0); }
        if (idx == x.n_rows) { return x(x.n_rows);  }

        double a,b;
        a = ( x(idx+1)*(y(idx) - y(idx-1)) + x(idx)*(y(idx-1) - y(idx+1)) + 
            x(idx-1)*(y(idx+1) - y(idx)) );
        b = ( x(idx+1)*x(idx+1)*(y(idx-1) - y(idx)) + x(idx)*x(idx)*(y(idx+1) - y(idx-1)) + 
            x(idx-1)*x(idx-1)*(y(idx) - y(idx+1)) );
        return -b/(2.*a);
    }

    float
    ncosest_fc_impl::calc_error(const float* in, const frowvec &freqs)
    {   
      cx_fmat B(d_calc_len, d_nfreqs);
      frowvec omega;

      cx_fcolvec in_vec(d_calc_len);
      for (int i = 0; i < d_calc_len; ++i)
      {
        assert(i<d_calc_len);
        in_vec(i) = gr_complex( in[i] , 0.f );
      }
      //cout << "in_vec\n" << in_vec;

      omega = 2.f*fdatum::pi*freqs/d_fs;
      //cout << "omega\n" << omega;

      //FIXME: Super naive
      for (int i = 0; i < d_nfreqs; ++i)
      {
        cx_fcolvec tmpcol(d_calc_len);
        
        for (int k = 0; k < d_calc_len; ++k)
        {
          tmpcol(k) = exp( gr_complex(0.f, k*omega(i)) );
        }
        B.col(i) = tmpcol;
      }

      //cx_fmat tmp(1,1);
      //tmp = 
      return real(as_scalar( (in_vec.t()*B) * (inv(B.t()*B))* (B.t()*in_vec) ));

      //return real(tmp(0,0));
    }

    float
    ncosest_fc_impl::calc_error2(const float* in, const int eps_idx)
    {   
      frowvec omega;

      fcolvec in_vec(in, d_calc_len);
      //cout << "in_vec\n" << in_vec;

      omega = 2.f*fdatum::pi*d_freqs/d_fs;
      //cout << "omega\n" << omega;

      cx_fmat tmp(1,1);
      //tmp = (in_vec.t()*B) * (inv(B.t()*B))* (B.t()*in_vec);

      return real(tmp(0,0));
    }    

    void
    ncosest_fc_impl::amp_est(cx_fcolvec &amp, const float* in, const float eps)
    {
      cx_fmat B(d_calc_len, d_nfreqs);
      frowvec omega;
      cx_fcolvec in_vec(d_calc_len);

      omega = 2.f*fdatum::pi*d_freqs.t()/d_fs*(1.f+eps);

      for (int i = 0; i < d_calc_len; ++i)
      {
        in_vec(i) = gr_complex( in[i] , 0.f );
      }

      for (int i = 0; i < d_nfreqs; ++i)
      {
        cx_fcolvec tmpcol(d_calc_len);
        
        for (int k = 0; k < d_calc_len; ++k)
        {
          tmpcol(k) = exp( gr_complex(0.f, k*omega(i)) );
        }
        B.col(i) = tmpcol;
      }

      amp = 2.f*inv(B.t()*B)*B.t()*in_vec;
      return;
    }

    int
    ncosest_fc_impl::work(int noutput_items,
        gr_vector_const_void_star &input_items,
        gr_vector_void_star &output_items)
    {
      static int COUNT = 0;
      const float  *in   = (const float*) input_items[0];
      float        *out0 = (float*)       output_items[0];
      gr_complex   *out1 = (gr_complex*)  output_items[1];
      float        *out2 = (float*)       output_items[2];

      int vlen = d_nfreqs/2;
      
      auto start = std::chrono::high_resolution_clock::now();
      d_tmr.reset();

      for (int i = 0; i < noutput_items; ++i)
      {
        Timer my_tmr;        
        fcolvec err_vec(d_neps,fill::zeros);
        for (int k = 0; k < d_neps; ++k)
        {
          frowvec freqs(d_nfreqs,fill::ones);
          freqs = d_freqs.t()*( 1.f + d_eps(k) );
          //cout << freqs;
          d_tmr2.reset();
          //err_vec(k) = calc_error(in+i*d_calc_len, freqs);
          if(COUNT==1000){
            cout << "ce2: " << d_tmr2.elapsed()*1e6 << endl;
            COUNT  = -1;
          }
          COUNT++;
          //err_vec(k) = 1./(abs(d_eps(k))+1.);
        }

        //cout << "err_vec\n"<< err_vec.t() << endl;
        float eps_max = argmax_interp_p(d_eps,err_vec);
        cx_fcolvec amps(d_nfreqs,fill::ones);
        amp_est(amps, in+i*d_calc_len, eps_max);
        
        //cout << "idx_max: "<<  eps_max << endl;
        int nn = 0;
        for (int n = 0; n < d_nfreqs; n+=2)
        {
            //cout << d_freqs(n)*(1+eps_max) << endl;
            assert(nn<d_freqs.size());
            out0[i*vlen+nn] = d_freqs(n)*(1.+eps_max);
            //cout << "amps[" << n/2 << "] = " << abs(amps(n)) << "  " << arg(amps(n))*180./fdatum::pi << endl;
            //cout << "amps[" << n/2 << "] = " << real(amps(n)) << "  " << imag(amps(n)) << endl;
            out1[i*vlen+nn] = amps(n);
            nn++;
        }
        *out2++ = eps_max*100.;
      }
      double s = d_tmr.elapsed();
      cout << "Did " << d_calc_len*noutput_items << " samples in " << s << " s. " 
        << d_calc_len*noutput_items/s*1.e-3 << " Ksps"  << endl;
      return noutput_items;
    }

  } /* namespace shfcc */
} /* namespace gr */
