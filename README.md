# Tikhonov-Regularization-Parameter-Selection-ECGI
## The project repository of EE798 Remote Image Formation Theory

In this repository, the study _Improving the spatial solution of electrocardiographic imaging: A new regularization parameter choice technique for the Tikhonov method_ is inspected and reimplemented using a new dataset and the Boundary Element Method. 

## Modifications
* In this reimplementation, a new parameter called *ratio* is defined to overcome the overregularization that is caused from the new experimental setup that can be seen below: 

![TestBeat_1_Ratio_1](https://user-images.githubusercontent.com/83376963/177035755-e5505399-4213-4796-93b5-3b1faa2df9c5.gif)

## Running the software

* The [presentation](https://github.com/kutay-ugurlu/Tikhonov-Regularization-Parameter-Selection-ECGI/blob/master/Presentation.pptx) and the (report)[https://github.com/kutay-ugurlu/Tikhonov-Regularization-Parameter-Selection-ECGI/blob/master/report/main.tex] of the project, along with the newly implemented [ADPC script](https://github.com/kutay-ugurlu/Tikhonov-Regularization-Parameter-Selection-ECGI/blob/master/ADPC.m) are shared in the repository.

* To run the experiments, run [test.m](https://github.com/kutay-ugurlu/Tikhonov-Regularization-Parameter-Selection-ECGI/blob/master/test.m)
