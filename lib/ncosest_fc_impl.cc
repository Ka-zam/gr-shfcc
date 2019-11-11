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
    ncosest_fc::make(float fs, std::vector<float> freqs , int nfreqs, float eps_abs, int Neps, int calc_len)
    {
      return gnuradio::get_initial_sptr
        (new ncosest_fc_impl(fs, freqs, nfreqs, eps_abs, Neps, calc_len));
    }

    /*
     * The private constructor
     */
    ncosest_fc_impl::ncosest_fc_impl(float fs, std::vector<float> freqs , int nfreqs, float eps_abs, int Neps, int calc_len)
      : gr::sync_decimator("ncosest_fc",
              gr::io_signature::make(1, 1, sizeof(float) ),
              gr::io_signature::make2(2, 2, sizeof(float)*nfreqs, sizeof(gr_complex)*nfreqs ), 
              calc_len)
    {
    	d_fs = fs;
    	d_nfreqs = 2*nfreqs;
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
      cout << "d_eps\n" << d_eps;
    }

    /*
     * Our virtual destructor.
     */
    ncosest_fc_impl::~ncosest_fc_impl()
    {
    }

    void
    ncosest_fc_impl::linspace(fcolvec &v, const float min_val, const float max_val)
    {
      int N = v.size();
      cout << "N\n" << N;
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
    ncosest_fc_impl::calc_error(const float* in, const frowvec &freqs)
    {
    
    	cx_fmat B(d_calc_len, d_nfreqs);
    	frowvec omega;

      cx_fcolvec in_vec(d_calc_len);
      for (int i = 0; i < d_calc_len; ++i)
      {
        in_vec(i) = gr_complex( in[i] , 0.f );
      }
      //cout << "in_vec\n" << in_vec;

      
    	//for (int i = 0; i < d_nfreqs; ++i)
    	//{
    	//	omega(i) = freqs.at(i)*2.f*fdatum::pi;
    	//}
      
      omega = 2.f*fdatum::pi*freqs/d_fs;
      cout << "omega\n" << omega;

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
      cout << "B\n" << B;
      fmat tmp3(size(B));
      tmp3 = real(B);
      tmp3.save("Br.dat",raw_ascii);
      tmp3 = imag(B);
      tmp3.save("Bi.dat",raw_ascii);


      cx_fmat tmp2(d_nfreqs,d_nfreqs);
      cout << "size(tmp2)\n" << tmp2.n_rows << ", " << tmp2.n_cols << endl;
      tmp2 = trans(B)*B;
      //cout << "B.t()*B\n" << B.t()*B;
      
      //fcolvec in_vec(in, d_calc_len);
      cx_fmat tmp(1,1);
      //tmp = (in_vec.t()*B) * (inv(B.t()*B))* (B.t()*in_vec) ;
      tmp(0,0) = 23.f;
      return real(tmp(0,0));
    	//return 0.f;
    }



    int
    ncosest_fc_impl::work(int noutput_items,
        gr_vector_const_void_star &input_items,
        gr_vector_void_star &output_items)
    {
      const float  *in   = (const float*) input_items[0];
      float        *out0 = (float*)       output_items[0];
      gr_complex   *out1 = (gr_complex*)  output_items[1];

      //fprintf(stderr, "NOI: %d\n", noutput_items);
      //fprintf(stderr, "d_nfreqs: %d\n", d_nfreqs);
      
      for (int i = 0; i < noutput_items; ++i)
      {
        
        fcolvec err_vec(d_neps);
        for (int k = 0; k < d_neps; ++k)
        {
          frowvec freqs(d_nfreqs,fill::ones);
          freqs = d_freqs.t()*( 1.f + d_eps(k) );
          cout << freqs;
          //cout << "d_eps\n" << d_eps;
          err_vec(k) = calc_error(in, freqs);
          
        }

        cout << err_vec;
        
        /*
      	for (int n = 0; n < d_nfreqs; ++n)
      	{
      		//out0[i*d_nfreqs  ] = 0.f;
      		//fprintf(stderr, "idx:%d\n", i*d_nfreqs+n);

      		//out0[i*d_nfreqs+n] = 1.f;
      		out0[i*d_nfreqs + n] = mean( in, d_calc_len);

      		//out1[i*d_nfreqs  ] = gr_complex(1.f,1.f);
      		out1[i*d_nfreqs+n] = gr_complex(1.f,1.f);
      		//out1[i*d_nfreqs + n] = gr_complex(1.f,0.f);
      	}
        */
      	in += d_calc_len;
      }
      
      
      return noutput_items;
    }

  } /* namespace shfcc */
} /* namespace gr */
