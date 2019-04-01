import numpy as np
from scipy import signal
from gnuradio.digital  import qam_constellation

def sinepulse( Nper = 3, fc = 1000.0 , fs = 96000.0 ):
	period = fs/fc
	N = int( np.ceil(period*Nper) )
	t = np.linspace( 0 , (N-1)/fs , N )

	return np.sin(2*np.pi*fc*t) * signal.triang(N)


class spiralqam():

	def __init__( self , N = 4 , R = 0.01 ):
		self.pts = self.calc_pts( N , R )
		self.dim = self.calc_dim( N , R )

	def points( self ):
		return self.pts

	def dimensionality( self ):
		return self.dim

	def calc_dim( self , N , R ):
		return 1

	def bits_per_symbol( self ):
		return np.log2(len(self.pts))

	def calc_pts( self , N , R ):
		m  =np.arange(1,N+1)
		tm = np.sqrt( (4*np.pi*m)**2*R*.5 + np.sqrt( (4*np.pi*m*R*.5)**2 + (4*np.pi*m)**2 )  )
		points = tm*np.exp(1j*tm)
		#n = sqrt( sum(c.*conj(c))/length(c) );

		points /= np.sqrt( np.sum( points*np.conj(points) )/len(points) )
		return tuple(points)
	
