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
#include "cexp_est_impl.h"
#include <volk/volk.h>


namespace gr {
  namespace shfcc {

    cexp_est::sptr
    cexp_est::make(float fs, int calc_len)
    {
      return gnuradio::get_initial_sptr
        (new cexp_est_impl(fs, calc_len));
    }

    /*
     * The private constructor
     */
    cexp_est_impl::cexp_est_impl(float fs, int calc_len)
      : gr::sync_decimator("cexp_est",
              gr::io_signature::make(1, 1, sizeof(gr_complex) ),
              gr::io_signature::make2(2, 2, sizeof(float) , sizeof(gr_complex) ),
              calc_len )
    {
    	d_fs = fs;
    	d_calc_len = calc_len;
    	d_alignment = volk_get_alignment();
    	d_cpx_data = (gr_complex *) volk_malloc( calc_len*sizeof(gr_complex) , d_alignment );
    	d_cpx_datb = (gr_complex *) volk_malloc( calc_len*sizeof(gr_complex) , d_alignment );
    	d_flt_data = (float *) volk_malloc( calc_len*sizeof(float) , d_alignment );
	    d_fft = new fft::fft_complex(d_calc_len);
    }

    /*
     * Our virtual destructor.
     */
    cexp_est_impl::~cexp_est_impl()
    {
    	delete d_fft;
    	volk_free( d_cpx_data );
    }

  	void 
  	cexp_est_impl::amest(float *freq , gr_complex *amplitude , const gr_complex *in_data  )
  	{
  		//Local data
  		uint16_t idx_us;
  		int32_t idx;
  		gr_complex pha = (1.f,0.f);
  		gr_complex pha_inc;
      gr_complex alpha,acp,acn;
	    float d[2]  = {0.f,0.f};
	    gr_complex Yn, Yp;

  		//First take forward FFT
  		memcpy( d_fft->get_inbuf() , in_data , d_calc_len );
        d_fft->execute();
        memcpy( d_cpx_data , d_fft->get_outbuf() , sizeof(gr_complex)*d_calc_len );

        volk_32fc_magnitude_squared_32f(d_flt_data , d_cpx_data , d_calc_len );
        // d_ftl_data = X*conj(X)
        volk_32f_index_max_16u( &idx_us , d_flt_data , d_calc_len );
        idx = (int) idx_us;
        // idx = argmax( abs(X) )

        //pha_inc = -2.f*M_PI/float(d_calc_len)*( idx + 0.5f );
        pha_inc = exp(gr_complex(0.f, -2.f*M_PI/float(d_calc_len)*( idx + 0.5f )));
        volk_32fc_s32fc_x2_rotator_32fc(d_cpx_datb, d_cpx_data, pha_inc, &pha, d_calc_len);
        // d_cpx_datb = Xp

        pha = (1.f,0.f);
        //d_pha_inc = exp( gr_complex(0.0 , 2.0*M_PI*(fc/d_fs) ) );
        pha_inc = exp(gr_complex(0.f, -2.f*M_PI/float(d_calc_len)*( idx - 0.5f )));
        volk_32fc_s32fc_x2_rotator_32fc(d_cpx_data, d_cpx_data, pha_inc, &pha, d_calc_len);
        // d_cpx_data = Xn


        // Q = 0
        // D == 1
        Yn = gr_complex(0.f,0.f);
        Yp = gr_complex(0.f,0.f);
        for (int i = 0; i < d_calc_len; ++i)
        {
          Yn += d_cpx_data[i];
          Yp += d_cpx_datb[i];
        }

        //ALG == 1
        d[0] = 0.5f*real( (Yp+Yn)/(Yp-Yn) );
        //alpha = gr_complex( 0.f , M_PI/float(d_calc_len)/( 1.f + exp( gr_complex(0.f,2.f*M_PI*d[0]))) );
        //acp = Yp*( d[0] + 0.5f );
        //acn = Yn*( d[0] - 0.5f );
        //amplitude = ( acp + acn )*alpha;


        // Q = 1
        pha_inc = exp(gr_complex(0.f, -2.f*M_PI/float(d_calc_len)*d[0]));
        volk_32fc_s32fc_x2_rotator_32fc(d_cpx_data, d_cpx_data, pha_inc, &pha, d_calc_len);
        // d_cpx_data = D*Xn
        volk_32fc_s32fc_x2_rotator_32fc(d_cpx_datb, d_cpx_datb, pha_inc, &pha, d_calc_len);
        // d_cpx_datb = D*Xp
        
        Yn = gr_complex(0.f,0.f);
        Yp = gr_complex(0.f,0.f);
        for (int i = 0; i < d_calc_len; ++i)
        {
          Yn += d_cpx_data[i];
          Yp += d_cpx_datb[i];
        } 
        d[1] = 0.5f*real( (Yp+Yn)/(Yp-Yn) );

        alpha = gr_complex( 0.f , 1.f )*float(M_PI)/float(d_calc_len)/( 1.f + exp( gr_complex(0.f,2.f*M_PI*(d[0] + d[1] ))) );
        acp = Yp*( d[0] + d[1] + 0.5f );
        acn = Yn*( d[0] + d[1] - 0.5f );

        *amplitude = ( acp + acn )*alpha;

        if (idx >= d_calc_len/2.f )
        {
          idx -= d_calc_len;
        }

        *freq = ( float(idx) + d[0] + d[1] )/float(d_calc_len);

  		return;
  	}


    int
    cexp_est_impl::work(int noutput_items,
        gr_vector_const_void_star &input_items,
        gr_vector_void_star &output_items)
    {
      const gr_complex *in = (const gr_complex *) input_items[0];
      float *out1 = (float *) output_items[0];
      gr_complex *out2 = (gr_complex *) output_items[1];

      for (int i = 0; i < noutput_items; ++i)
      {
      	amest( &out1[i] , &out2[i] , &in[ i*d_calc_len ] );
      	//out1[i] = real( in[ i*d_calc_len ] );
      	//out2[i] = conj( in[ i*d_calc_len ] );
      }

      // Tell runtime system how many output items we produced.
      return noutput_items;
    }

  } /* namespace shfcc */
} /* namespace gr */

