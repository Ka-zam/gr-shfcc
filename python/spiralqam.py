import numpy as np
from gnuradio.digital  import qam_constellation

class spiralqam():

	def __init__( self , N = 4 , R = 0.01 ):
		self.points = self.calc_pts( N , R )
		self.dimensionality = self.calc_dim()

	def calc_dim( self ):
		return 1


	def calc_pts( self , N=4 , R=0.01 ):
		m  =np.arange(1,N+1)
		tm = np.sqrt( (4*np.pi*m)**2*R*.5 + np.sqrt( (4*np.pi*m*R*.5)**2 + (4*np.pi*m)**2 )  )
		points = tm*np.exp(1j*tm)
		points /= np.max(np.abs(points))
		return tuple(points)
	
