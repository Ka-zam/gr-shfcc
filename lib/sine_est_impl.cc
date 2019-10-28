/* -*- c++ -*- */
/*                     GNU GENERAL PUBLIC LICENSE
 *                        Version 3, 29 June 2007
 * 
 *  Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
 *  Everyone is permitted to copy and distribute verbatim copies
 *  of this license document, but changing it is not allowed.
 */

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <gnuradio/io_signature.h>
#include "sine_est_impl.h"

namespace gr {
  namespace shfcc {

    sine_est::sptr
    sine_est::make(float fs, int calc_len, int alg, int iters, float freq_scale)
    {
      return gnuradio::get_initial_sptr
        (new sine_est_impl(fs, calc_len, alg, iters, freq_scale));
    }

    /*
     * The private constructor
     */
    sine_est_impl::sine_est_impl(float fs, int calc_len, int alg, int iters, float freq_scale)
      : gr::sync_decimator("sine_est",
              gr::io_signature::make(1, 1, sizeof(float)),
              gr::io_signature::make3(3, 3, sizeof(float), sizeof(gr_complex), sizeof(float) ),
              calc_len )
    {
      d_fs = fs;
      d_fscale = d_fs*freq_scale;
      d_calc_len = calc_len;
      d_algorithm = alg;
      d_iterations = iters;
      d_alignment = volk_get_alignment();
      d_cpx_data = (gr_complex *) volk_malloc( d_calc_len*sizeof(gr_complex) , d_alignment );
      d_cpx_datb = (gr_complex *) volk_malloc( d_calc_len*sizeof(gr_complex) , d_alignment );
      d_cpx_datc = (gr_complex *) volk_malloc( d_calc_len*sizeof(gr_complex) , d_alignment );
      d_flt_data = (float *) volk_malloc( d_calc_len*sizeof(float) , d_alignment );
      d_fft = new fft::fft_complex(d_calc_len);	
    }

    /*
     * Our virtual destructor.
     */
    sine_est_impl::~sine_est_impl()
    {
    }

    void
    sine_est_impl::set_calc_len(size_t calc_len)
    {
      gr::thread::scoped_lock lock(d_mtx); 
      d_calc_len = calc_len;
      
      delete d_fft;
      d_fft = new fft::fft_complex(calc_len);
      
      volk_free( d_cpx_data );
      volk_free( d_cpx_datb );
      volk_free( d_cpx_datc );
      volk_free( d_flt_data );      

      d_cpx_data = (gr_complex *) volk_malloc( d_calc_len*sizeof(gr_complex) , d_alignment );
      d_cpx_datb = (gr_complex *) volk_malloc( d_calc_len*sizeof(gr_complex) , d_alignment );
      d_cpx_datc = (gr_complex *) volk_malloc( d_calc_len*sizeof(gr_complex) , d_alignment );
      d_flt_data = (float *)      volk_malloc( d_calc_len*sizeof(float)      , d_alignment );
      
      set_decimation(d_calc_len);
      return;
    }    

    void
    mean(gr_complex* m, gr_complex* vec, int len)
    {
    	*m = gr_complex(0.f,0.f);
    	for (int i = 0; i < len; ++i)
    	{
    		*m += vec[i];
    	}
    	*m /= (float) len;
    	return;
    }

    void 
    sine_est_impl::yeest(float *freq , gr_complex *amplitude , const float *in_data  )
    {
      //Constants
      constexpr float NEGTWOPI  =  -6.2831853071795862f;
      constexpr float NEGFOURPI = -12.5663706143591725f;

      //Local data
      uint16_t idx_us;
      int32_t idx;
      gr_complex pha = gr_complex(1.f,0.f);
      gr_complex pha_inc;
      gr_complex alpha;
      gr_complex Xp05, Xn05, Lp05, Ln05, Sp05, Sn05;
      float delta;


      /*
      Init parameters
      */
      for (int i = 0; i < d_calc_len; ++i)
      {
        d_cpx_datc[i] = gr_complex(in_data[i],0.f);
      }
      delta = 0.f;
      *amplitude = gr_complex(0.f,0.f);
      /*
      for (int i = 0; i < d_calc_len; ++i)
      {
      	fprintf(stderr, "in[%d]: %9.3f+j%9.3f\n", i , real(d_cpx_datc[i]), imag(d_cpx_datc[i]));
      }
      */
      /*
      First take forward FFT
      */
      memcpy( d_fft->get_inbuf() , d_cpx_datc , sizeof(gr_complex)*d_calc_len );
      d_fft->execute();
      memcpy( d_cpx_data , d_fft->get_outbuf() , sizeof(gr_complex)*d_calc_len );
       //d_cpx_data = X = FFT(in)

      volk_32fc_magnitude_squared_32f(d_flt_data , d_cpx_data , d_calc_len );
        // d_flt_data = X*conj(X)

      uint32_t max_calc_len;
      if (d_calc_len%2 == 0) { max_calc_len = d_calc_len/2; }
      else { max_calc_len = d_calc_len/2 + 1; }

      volk_32f_index_max_16u( &idx_us , d_flt_data , max_calc_len );
      idx = (int) idx_us;
        // idx = argmax( abs(X) )
      //fprintf(stderr, "idx: %d\n", idx);

      for (int q = 0; q < d_iterations; ++q)
      {
      	//fprintf(stderr, "Q: %d\n", q);
	      pha     = gr_complex(1.f,0.f);
	      pha_inc = exp(gr_complex(0.f, NEGTWOPI/d_calc_len*( idx + delta + 0.5f )));
	      volk_32fc_s32fc_x2_rotator_32fc(d_cpx_datb, d_cpx_datc , pha_inc, &pha, d_calc_len);
	      // d_cpx_datb = in.*exp(-1j*2*pi/N*(m+delta+0.5)*[0:d_calc_len-1])
/*
      for (int i = 0; i < d_calc_len; ++i)
      {
      	fprintf(stderr, "Xp05[%d]: %9.3f+j%9.3f\n", i , real(d_cpx_datb[i]), imag(d_cpx_datb[i]));
      }
      */
      
	      Xp05 = gr_complex(0.f,0.f);
	      for (int i = 0; i < d_calc_len; ++i)
	      {
	      	Xp05 += d_cpx_datb[i];
	      }
	      Xp05 /= (float) d_calc_len;
      	//fprintf(stderr, "Xp05: %9.3f+j%9.3f\n",  real(Xp05), imag(Xp05));

	      pha     = gr_complex(1.f,0.f);
	      pha_inc = exp(gr_complex(0.f, NEGTWOPI/d_calc_len*( idx + delta - 0.5f )));
	      volk_32fc_s32fc_x2_rotator_32fc(d_cpx_data, d_cpx_datc, pha_inc, &pha, d_calc_len);
	      // d_cpx_data = in.*exp(-1j*2*pi/N*(m+delta-0.5)*[0:d_calc_len-1])
	      Xn05 = gr_complex(0.f,0.f);
	      for (int i = 0; i < d_calc_len; ++i)
	      {
	      	Xn05 += d_cpx_data[i];
	      }
	      Xn05 /= (float) d_calc_len;
      	//fprintf(stderr, "Xn05: %9.3f+j%9.3f\n",  real(Xn05), imag(Xn05));

	      Lp05 = conj(*amplitude)*( 1.f + exp(gr_complex(0.f, NEGFOURPI*delta)) )/
	      			( 1.f - exp(gr_complex(0.f,NEGFOURPI/d_calc_len*(idx + delta + 0.25f))) );
	      Lp05 /= (float) d_calc_len;

	      Ln05 = conj(*amplitude)*( 1.f + exp(gr_complex(0.f, NEGFOURPI*delta)) )/
	      			( 1.f - exp(gr_complex(0.f,NEGFOURPI/d_calc_len*(idx + delta - 0.25f))) );
	      Ln05 /= (float) d_calc_len;

	      Sp05 = Xp05 - Lp05;
	      Sn05 = Xn05 - Ln05;

	      switch (d_algorithm){
	        case 1:
	          delta += 0.5f*real( (Sp05+Sn05)/(Sp05-Sn05) );
	          break;
	        case 2:
	          delta += 0.5f*( abs(Sp05) - abs(Sn05) )/( abs(Sp05) + abs(Sn05) ) ;
	          break;
	        default:
	          fprintf(stderr,"%s\n","gr-sapp::cexp_est error: Unknown algorithm" );
	          exit(0);
	      }
	      //fprintf(stderr, "delta: %f\n", delta);

	      pha     = gr_complex(1.f,0.f);
	      pha_inc = exp(gr_complex(0.f, NEGTWOPI/d_calc_len*( idx + delta )));
	      volk_32fc_s32fc_x2_rotator_32fc(d_cpx_data, d_cpx_datc , pha_inc, &pha, d_calc_len);
	      alpha = gr_complex(0.f,0.f);
	      for (int i = 0; i < d_calc_len; ++i)
	      {
	      	alpha += d_cpx_data[i];
	      }

	      alpha -= conj(*amplitude)*( 1.f - exp(gr_complex(0.f,NEGFOURPI*delta)))/
	      	( 1.f - exp(gr_complex( 0.f, NEGFOURPI/d_calc_len*(idx+delta) )));

	      *amplitude = alpha/( (float) d_calc_len );
      }
      *amplitude *= 2.f;
 //fprintf(stderr, "freq: %f\n", (idx+delta)/d_calc_len);

      *freq = (idx + delta)/( (float) d_calc_len);
      return;
    }    

    void
    sine_est_impl::snr_est(float *snr,  const float *freq, const gr_complex *amplitude, const float *in_data)
    {
      constexpr float TWOPI  =  6.2831853071795862f;    	
      float sig_pwr;
      float nse_pwr = 0.f;

      /*
      Use d_cpx_data for reconstructed signal
      */
      //gr_complex pha_inc = gr_complex( std::cos(2.f*M_PI*(*freq)), std::sin(2.f*M_PI*(*freq)) ) ;
      //gr_complex pha_inc = std::exp( gr_complex( 0.f , 2.f*M_PI*(*freq) ) );
      const float pha_inc  = TWOPI*(*freq);
      const float A_hat = abs(*amplitude);
      float pha = arg(*amplitude);

      //gr_complex _pha = *amplitude;
      /*
      drop temporary phase after done, rotate unity vector
      */
      //volk_32fc_s32fc_x2_rotator_32fc(d_cpx_data, d_cpx_ones, pha_inc, &_pha, d_calc_len);
      /*
      d_cpx_data = A_hat * exp( 1j*2*pi*f_hat )
      */
      for (int i = 0; i < d_calc_len; ++i)
      {
        d_flt_data[i] = A_hat*cos(pha) - in_data[i];
      	pha += pha_inc;
      }
      /*
      d_cpx_data = X_hat(k) - X(k)
      */      

      /*
      By definition this is the signal power
      */
      sig_pwr = A_hat*A_hat*.5f;
      //fprintf(stderr, "sig_pwr: %9.3f\n", sig_pwr);

      for (int i = 0; i < d_calc_len; ++i)
      {
        nse_pwr += d_flt_data[i]*d_flt_data[i];
      }
      //nse_pwr /= .5f*(d_calc_len - 1);
      nse_pwr /= .5f*(d_calc_len - 0);
      //fprintf(stderr, "nse_pwr: %9.3f\n", nse_pwr);

      *snr = 10.f*(std::log10(sig_pwr) - std::log10(nse_pwr));
      return;
    }    

    int
    sine_est_impl::work(int noutput_items,
        gr_vector_const_void_star &input_items,
        gr_vector_void_star &output_items)
    {
      gr::thread::scoped_lock lock(d_mtx);     	
      const float *in   = (const float *) input_items[0];
      float       *out1 = (float *)       output_items[0];
      gr_complex  *out2 = (gr_complex *)  output_items[1];
      float       *out3 = (float *)       output_items[2];

      for (int i = 0; i < noutput_items; i++)
      {
      	//fprintf(stderr, "%s\n", "");
        yeest( out1+i, out2+i, in + i*d_calc_len );
        float freq_tmp;
        freq_tmp = *(out1+i); //Save for snr_est
        *(out1+i) *= d_fscale; //Report fequency in scaled Hz
        
        //fprintf(stderr, "amp: %f ", std::abs(*(out2+i)) );
        //fprintf(stderr, "pha: %f ", std::arg(*(out2+i)) );
        //fprintf(stderr, "frq: %f ", *(out1+i) );
        
        /*
        snr_est needs the fractional frequency
        */
        snr_est( out3+i, &freq_tmp, out2+i,  in + i*d_calc_len );
        //*(out3+i) = 12.34f; //SNR
        
        //fprintf(stderr, "snr: %f\n", *(out3+i) );
        
      }      

      return noutput_items;
    }

  } /* namespace shfcc */
} /* namespace gr */

