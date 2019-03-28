import numpy as np
from gnuradio.digital  import qam_constellation

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


	def calc_pts( self , N , R ):
		m  =np.arange(1,N+1)
		tm = np.sqrt( (4*np.pi*m)**2*R*.5 + np.sqrt( (4*np.pi*m*R*.5)**2 + (4*np.pi*m)**2 )  )
		points = tm*np.exp(1j*tm)
		#n = sqrt( sum(c.*conj(c))/length(c) );

		points /= np.sqrt( np.sum( points*np.conj(points) )/len(points) )
		return tuple(points)
	
