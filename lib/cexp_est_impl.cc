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
    	volk_free( d_cpx_datb );
    	volk_free( d_flt_data );
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
  	cexp_est_impl::amest(float *freq , gr_complex *amplitude , const gr_complex *in_data  )
  	{
  		//Local data
  		uint16_t idx_us;
  		int32_t idx;
  		gr_complex pha = gr_complex(1.f,0.f);
  		gr_complex pha_inc;
        gr_complex alpha , acp , acn;
	    float d[2]  = {0.f,0.f};
	    gr_complex Yn, Yp;

  		//First take forward FFT
  		//printz("indata: " , in_data , d_calc_len);
  		memcpy( d_fft->get_inbuf() , in_data , sizeof(gr_complex)*d_calc_len );
        d_fft->execute();
        memcpy( d_cpx_data , d_fft->get_outbuf() , sizeof(gr_complex)*d_calc_len );
        //printz("fft data: " , d_cpx_data , d_calc_len);

        volk_32fc_magnitude_squared_32f(d_flt_data , d_cpx_data , d_calc_len );
        // d_ftl_data = X*conj(X)
        volk_32f_index_max_16u( &idx_us , d_flt_data , d_calc_len );
        //printz( "mag squared: " , d_flt_data , d_calc_len );
        idx = (int) idx_us;
        //printz("idx max: ", idx);
        // idx = argmax( abs(X) )

        //pha_inc = -2.f*M_PI/float(d_calc_len)*( idx + 0.5f );
        pha_inc = exp(gr_complex(0.f, -2.f*M_PI/float(d_calc_len)*( idx + 0.5f )));
        //printz("pha_inc: ", pha_inc);
        //printz("pha : ", pha);
        ////////////////////////////////////
        /*
        for (int i = 0; i < d_calc_len; ++i)
        {
        	SCRATCH[i] = gr_complex(1.f,0.f);
        }
        */
        ///////////////////////////////////
        volk_32fc_s32fc_x2_rotator_32fc(d_cpx_datb, in_data , pha_inc, &pha, d_calc_len);
        //volk_32fc_s32fc_x2_rotator_32fc(d_cpx_datb, SCRATCH , pha_inc, &pha, d_calc_len);
        // d_cpx_datb = Xp
        //printz("Xp: " , d_cpx_datb , d_calc_len );
        pha = gr_complex(1.f,0.f);
        //d_pha_inc = exp( gr_complex(0.0 , 2.0*M_PI*(fc/d_fs) ) );
        pha_inc = exp(gr_complex(0.f, -2.f*M_PI/float(d_calc_len)*( idx - 0.5f )));
        volk_32fc_s32fc_x2_rotator_32fc(d_cpx_data, in_data, pha_inc, &pha, d_calc_len);
        // d_cpx_data = Xn
        //printz("Xn: " , d_cpx_data , d_calc_len );


        // Q = 0
        // D == 1
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
        d[0] = 0.5f*real( (Yp+Yn)/(Yp-Yn) );
        //printz("d: " , d , 2 );
        //alpha = gr_complex( 0.f , M_PI/float(d_calc_len)/( 1.f + exp( gr_complex(0.f,2.f*M_PI*d[0]))) );
        //acp = Yp*( d[0] + 0.5f );
        //acn = Yn*( d[0] - 0.5f );
        //amplitude = ( acp + acn )*alpha;


        // Q = 1
        pha = gr_complex(1.f,0.f);
        pha_inc = exp(gr_complex(0.f, -2.f*M_PI/float(d_calc_len)*d[0]));
        volk_32fc_s32fc_x2_rotator_32fc(d_cpx_data, d_cpx_data, pha_inc, &pha, d_calc_len);
        // d_cpx_data = D*Xn
        //printz("D*Xn: " , d_cpx_data , d_calc_len );
        pha = gr_complex(1.f,0.f);
        volk_32fc_s32fc_x2_rotator_32fc(d_cpx_datb, d_cpx_datb, pha_inc, &pha, d_calc_len);
        // d_cpx_datb = D*Xp
        //printz("D*Xp: " , d_cpx_datb , d_calc_len );
        
        Yn = gr_complex(0.f,0.f);
        Yp = gr_complex(0.f,0.f);
        for (int i = 0; i < d_calc_len; ++i)
        {
          Yn += d_cpx_data[i];
          Yp += d_cpx_datb[i];
        } 
        //printz("Yp: " , Yp  );
        //printz("Yn: " , Yn );
        d[1] = 0.5f*real( (Yp+Yn)/(Yp-Yn) );
        //printz("d: " , d , 2 );

        alpha = gr_complex( 0.f , 1.f )*float(M_PI)/float(d_calc_len)/( 1.f + exp( gr_complex(0.f,2.f*M_PI*(d[0] + d[1] ))) );
        acp = Yp*( d[0] + d[1] + 0.5f );
        acn = Yn*( d[0] + d[1] - 0.5f );
        //printz("alpha: " , alpha  );
        //printz("acp: " , acp  );
        //printz("acn: " , acn  );

        *amplitude = ( acp + acn )*alpha;
        //printz("amp: " , *amplitude  );

        if (idx >= float(d_calc_len)/2.f )
        {
          idx -= d_calc_len;
        }

        *freq = ( float(idx) + d[0] + d[1] )/float(d_calc_len);
        //printz("freq: " , *freq  );

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

      cout << "output items: " << noutput_items << endl;
      for (int i = 0; i < noutput_items; i++)
      {
      	cout << "i: " << i << endl;
      	amest( &out1[i] , &out2[i] , &in[ i*d_calc_len ] );
      	printz("freq: " , out1[i] ) ;
      	printz("amp:  " , out2[i] ) ;
      	//out1[i] = real( in[ i*d_calc_len ] );
      	//out2[i] = conj( in[ i*d_calc_len ] );
      }

      // Tell runtime system how many output items we produced.
      cout << noutput_items << endl;
      return noutput_items;
    }

  } /* namespace shfcc */
} /* namespace gr */

