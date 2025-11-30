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
    cexp_est::make(float fs, int calc_len, int algo, int iter, float freq_scale)
    {
      return std::make_shared<cexp_est_impl>(fs, calc_len, algo, iter, freq_scale);
    }

    /*
     * The private constructor
     */
    cexp_est_impl::cexp_est_impl(float fs, int calc_len, int algo, int iter, float freq_scale)
      : gr::sync_decimator("cexp_est",
              gr::io_signature::make(1, 1, sizeof(gr_complex) ),
              gr::io_signature::make3(3, 3, sizeof(float) , sizeof(gr_complex) , sizeof(float)),
              calc_len )
    {
      d_fs = fs;
      d_fscale = d_fs*freq_scale;
      d_calc_len = calc_len;
      d_algorithm = algo;
      d_iterations = iter;
      d_alignment = volk_get_alignment();
      d_cpx_data = (gr_complex *) volk_malloc( calc_len*sizeof(gr_complex) , d_alignment );
      d_cpx_datb = (gr_complex *) volk_malloc( calc_len*sizeof(gr_complex) , d_alignment );
      d_cpx_datc = (gr_complex *) volk_malloc( calc_len*sizeof(gr_complex) , d_alignment );
      d_cpx_ones = (gr_complex *) volk_malloc( calc_len*sizeof(gr_complex) , d_alignment );
      d_flt_data = (float *) volk_malloc( calc_len*sizeof(float) , d_alignment );
      d_residuals = (float *) volk_malloc( d_iterations*sizeof(float) , d_alignment );
      d_fft = new fft::fft_complex_fwd(d_calc_len);
      
      for (int i = 0; i < d_calc_len; ++i)        
      {
        d_cpx_ones[i] = gr_complex(1.f,0.f);
      }      
    }
    /*
     * Our virtual destructor.
     */
    cexp_est_impl::~cexp_est_impl()
    {
      delete d_fft;
      volk_free( d_cpx_data );
      volk_free( d_cpx_datb );
      volk_free( d_cpx_datc );
      volk_free( d_cpx_ones );
      volk_free( d_flt_data );
      volk_free( d_residuals);
      //fprintf(stderr, "%s\n", "cexp_est destroyed");
    }

    void 
    cexp_est_impl::printz(const string &s,const int32_t &x){
      //cout << fixed << setprecision(4);
      cout << s << " " << x << endl;
    }        

    void 
    cexp_est_impl::printz(const string &s,const gr_complex &x){
    	cout << fixed << setprecision(4);
    	cout << s << " " << real(x) << showpos << imag(x) << "i" << endl;
    }

    void 
    cexp_est_impl::printz(const string &s, const gr_complex *x,const int N){
    	cout << fixed << setprecision(4);
    	for (int k=0;k<N;k++){
    		cout  << noshowpos << s << "[" << k << "]: " 
    		<< real(x[k]) << showpos << imag(x[k]) << "i" << endl;
    	}
    	cout << endl;
    }

    void 
    cexp_est_impl::printz(const string &s, float *x,const int N){
    	cout << fixed << setprecision(4);
    	for (int k=0;k<N;k++){
    		cout  << noshowpos << s << "[" << k << "]: " 
    		<< x[k] << endl;
    	}
    	cout << endl;
    }

    void 
    cexp_est_impl::printz(const string &s, int8_t *x,const int N){
    	for (int k=0;k<N;k++){
    		cout  
    		<< noshowpos 
    		<< s << "[" << k << "]: " 
    		<< showpos 
    		<< +x[k] << endl;
    	}
    	cout << endl;
    }

    void 
    cexp_est_impl::printz(const string &s, float *x,const int rows, const int cols){
    	cout << s << endl;
    	cout << fixed << setprecision(4) << noshowpos;
	//Column Major Order
    	for (int r=0;r<rows;r++){
    		for (int c=0;c<cols;c++){
    			int idx = r*cols + c;			
    			if( idx > rows*cols-1) return;
    			cout  << idx << ":" << x[idx] << "  ";
    		}
    		cout << endl;
    	}
    	cout << endl;
    }    

    void
    cexp_est_impl::set_calc_len(size_t calc_len)
    {
      gr::thread::scoped_lock lock(d_mtx); 
      d_calc_len = calc_len;
      
      delete d_fft;
      d_fft = new fft::fft_complex_fwd(calc_len);
      
      volk_free( d_cpx_data );
      volk_free( d_cpx_datb );
      volk_free( d_cpx_datc );
      volk_free( d_cpx_ones );      
      volk_free( d_flt_data );      

      d_cpx_data = (gr_complex *) volk_malloc( calc_len*sizeof(gr_complex) , d_alignment );
      d_cpx_datb = (gr_complex *) volk_malloc( calc_len*sizeof(gr_complex) , d_alignment );
      d_cpx_datc = (gr_complex *) volk_malloc( calc_len*sizeof(gr_complex) , d_alignment );
      d_cpx_ones = (gr_complex *) volk_malloc( calc_len*sizeof(gr_complex) , d_alignment );
      d_flt_data = (float *)      volk_malloc( calc_len*sizeof(float)      , d_alignment );

      for (int i = 0; i < d_calc_len; ++i)        
      {
        d_cpx_ones[i] = gr_complex(1.f,0.f);
      }
      
      set_decimation(calc_len);
      
      return;
    }    
    void 
    cexp_est_impl::amest(float *freq , gr_complex *amplitude , const gr_complex *in_data  )
    {
      //Local data
      uint16_t idx_us;
      int32_t idx;
      gr_complex pha = gr_complex(1.f,0.f);
      gr_complex pha_inc;
      gr_complex alpha , acp , acn;
      gr_complex Yn, Yp;

      /*
      Init parameters
      */
      for (int i = 0; i < d_iterations; ++i)
      {
        d_residuals[i] = 0.f;
      }
      /*
      First take forward FFT
      */
        //printz("calc_len: ", d_calc_len);
        //printz("indata: " , in_data , d_calc_len);
      memcpy( d_fft->get_inbuf() , in_data , sizeof(gr_complex)*d_calc_len );
      d_fft->execute();
      memcpy( d_cpx_data , d_fft->get_outbuf() , sizeof(gr_complex)*d_calc_len );
        //printz("fft data: " , d_cpx_data , d_calc_len);

      volk_32fc_magnitude_squared_32f(d_flt_data , d_cpx_data , d_calc_len );
      // d_flt_data = X*conj(X)

      volk_32f_index_max_16u( &idx_us , d_flt_data , d_calc_len );
        //printz( "mag squared: " , d_flt_data , d_calc_len );
      idx = (int) idx_us;
        //printz("idx max: ", idx);
      // idx = argmax( abs(X) )

      pha_inc = exp(gr_complex(0.f, -2.f*M_PI/float(d_calc_len)*( idx + 0.5f )));
        //printz("pha_inc: ", pha_inc);
        //printz("pha : ", pha);
      volk_32fc_s32fc_x2_rotator_32fc(d_cpx_datb, in_data , pha_inc, &pha, d_calc_len);
      // d_cpx_datb = Xp
        //printz("Xp: " , d_cpx_datb , d_calc_len );

      pha = gr_complex(1.f,0.f);
      pha_inc = exp(gr_complex(0.f, -2.f*M_PI/float(d_calc_len)*( idx - 0.5f )));
      volk_32fc_s32fc_x2_rotator_32fc(d_cpx_data, in_data, pha_inc, &pha, d_calc_len);
      // d_cpx_data = Xn
        //printz("Xn: " , d_cpx_data , d_calc_len );


      // Q = 0
      // The first iteration is special since D == 1 and we don't need the dot product
      Yn = gr_complex(0.f,0.f);
      Yp = gr_complex(0.f,0.f);
      for (int i = 0; i < d_calc_len; ++i)
      {
        Yn += d_cpx_data[i];
        Yp += d_cpx_datb[i];
      }
        //printz("Yp: " , Yp  );
        //printz("Yn: " , Yn );
      //ALG == 1
      switch (d_algorithm){
        case 1:
          d_residuals[0] = 0.5f*real( (Yp+Yn)/(Yp-Yn) );
          break;
        case 2:
          d_residuals[0] = 0.5f*( abs(Yp) - abs(Yn) )/( abs(Yp) + abs(Yn) ) ;
          break;
        default:
          fprintf(stderr,"%s\n","gr-sapp::cexp_est error: Unknown algorithm" );
          exit(0);
      }


      // Q = 1
      float residuals_partial_sum = 0.f;
        //printf("res_sum %f\n", residuals_partial_sum);
      for (int q = 1; q < d_iterations; ++q)
      {
        pha = gr_complex(1.f,0.f);
        residuals_partial_sum += d_residuals[q-1];
          //printf("res_sum %f\n", residuals_partial_sum);
        pha_inc = exp(gr_complex(0.f, -2.f*M_PI/float(d_calc_len)*residuals_partial_sum));

        volk_32fc_s32fc_x2_rotator_32fc(d_cpx_datc, d_cpx_data, pha_inc, &pha, d_calc_len);
        // d_cpx_datc = D*Xn
          //printz("D*Xn: " , tmp1 , d_calc_len );
        Yn = gr_complex(0.f,0.f);
        for (int i = 0; i < d_calc_len; ++i)
        {
          Yn += d_cpx_datc[i];
        }         

        pha = gr_complex(1.f,0.f);
        volk_32fc_s32fc_x2_rotator_32fc(d_cpx_datc, d_cpx_datb, pha_inc, &pha, d_calc_len);
        // d_cpx_datc = D*Xp
          //printz("D*Xp: " , tmp2 , d_calc_len );

        Yp = gr_complex(0.f,0.f);
        for (int i = 0; i < d_calc_len; ++i)
        {
          Yp += d_cpx_datc[i];
        } 
        switch (d_algorithm){
          case 1:
            d_residuals[q] = 0.5f*real( (Yp+Yn)/(Yp-Yn) );
            break;
          case 2:
            d_residuals[q] = 0.5f*( abs(Yp) - abs(Yn) )/( abs(Yp) + abs(Yn) ) ;
            break;
          default:
            fprintf(stderr,"%s\n","gr-sapp::cexp_est error: Unknown algorithm" );
            exit(0);
        }  
        //printz("Yp: " , Yp  );
        //printz("Yn: " , Yn );
        //printf("d_residuals[%d]: %10.8f\n" , q, d_residuals[q] );
      }
        //printz("d_residual" , d_residuals , d_iterations );

      if (idx >= d_calc_len*.5f )
      {
        idx -= d_calc_len;
      }
        //printz("idx: ", idx);

      //Sum of all residuals now
      residuals_partial_sum += d_residuals[d_iterations-1];
        //printz("d_res", residuals_partial_sum);
      *freq = ( idx + residuals_partial_sum )/d_calc_len;
        //printf("freq: %8.6f\n" , *freq  );
      /*
      Amplitude and phase estimate
      */
      pha = gr_complex(1.f,0.f);
      pha_inc = exp(gr_complex(0.f, -2.f*M_PI*(*freq)) );
      volk_32fc_s32fc_x2_rotator_32fc(d_cpx_data, in_data, pha_inc, &pha, d_calc_len);
      *amplitude = gr_complex(0.f,0.f);
      for (int i = 0; i < d_calc_len; ++i)
      {
        *amplitude += d_cpx_data[i];
      }
      *amplitude /= d_calc_len;
        //printz("amp: " , *amplitude  );
      return;
    }

    void
    cexp_est_impl::snr_est(float *snr,  const float *freq, const gr_complex *amplitude, const gr_complex *in_data)
    {
      float sig_pwr;
      float nse_pwr = 0.f;
      //gr_complex cj = gr_complex(0.f,1.f);

      /*
      Use d_cpx_data for reconstructed signal
      */
      gr_complex pha_inc = gr_complex( std::cos(2.f*M_PI*(*freq)), std::sin(2.f*M_PI*(*freq)) ) ;
      //gr_complex pha_inc = std::exp( gr_complex( 0.f , 2.f*M_PI*(*freq) ) );

      gr_complex _pha = *amplitude;
      /*
      drop temporary phase after done, rotate unity vector
      */
      volk_32fc_s32fc_x2_rotator_32fc(d_cpx_data, d_cpx_ones, pha_inc, &_pha, d_calc_len);
      /*
      d_cpx_data = A_hat * exp( 1j*2*pi*f_hat )
      */

      for (int i = 0; i < d_calc_len; ++i)
      {
        d_cpx_data[i] -= in_data[i];
      }
      /*
      d_cpx_data = X_hat(k) - X(k)
      */      

      /*
      By definition this is the signal power
      */
      sig_pwr = std::real( (*amplitude)*std::conj(*amplitude) );

      for (int i = 0; i < d_calc_len; ++i)
      {
        nse_pwr += std::real( d_cpx_data[i]*std::conj(d_cpx_data[i]) );
      }
      nse_pwr /= d_calc_len - 1;
      *snr = 10.f*(std::log10(sig_pwr) - std::log10(nse_pwr));
      return;
    }



    int
    cexp_est_impl::work(int noutput_items,
        gr_vector_const_void_star &input_items,
        gr_vector_void_star &output_items)
    {
      gr::thread::scoped_lock lock(d_mtx); 

      const gr_complex *in = (const gr_complex *) input_items[0];
      float *out1 = (float *) output_items[0];
      gr_complex *out2 = (gr_complex *) output_items[1];
      float *out3 = (float *) output_items[2];

      //cout << "noutput_items: " << noutput_items << endl;
      for (int i = 0; i < noutput_items; i++)
      {
        amest( out1+i, out2+i, in + i*d_calc_len );
        float freq_tmp;
        freq_tmp = *(out1+i); //Save for snr_est
        *(out1+i) *= d_fscale; //Report fequency in scaled Hz
        /*
        fprintf(stderr, "amp: %f ", std::abs(*(out2+i)) );
        fprintf(stderr, "pha: %f ", std::arg(*(out2+i)) );
        fprintf(stderr, "frq: %f ", *(out1+i)*d_fs );
        */
        /*
        snr_est needs the fractional frequency
        */
        snr_est( out3+i, &freq_tmp, out2+i,  in + i*d_calc_len );
        //*(out3+i) = 12.34f; //Report fequency in Hz
        /*
        fprintf(stderr, "snr: %f\n", *(out3+i) );
        */
      }
      return noutput_items;
    }
  } /* namespace shfcc */
} /* namespace gr */