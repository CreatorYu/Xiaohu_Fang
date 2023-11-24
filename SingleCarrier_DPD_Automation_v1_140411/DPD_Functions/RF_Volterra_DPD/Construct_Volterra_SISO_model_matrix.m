    % % 4th derivation
function A=Construct_Volterra_SISO_model_matrix(x_in1,start,m,N,M1,M3,M5)
       count=1;
       for i1=0:M1
           A(:,count)=x_in1(start-i1*m:N-i1*m);
           count=count+1;
       end
       for i1=0:M3
           for i2=i1:M3
               for i3=i2:M3
                   distortion=  Third_order_SingleBand_distortion(x_in1,i1,i2,i3,start,m,N) ;                        
                   A(:,count)= distortion;
                   count=count+1;
               end
           end
       end
       
%        for i1=0:M3
%            for i2=0:M3
%                for i3=i2:M3
%                    distortion=   Third_order_Mutual_distortion(x_in1,x_in2,x_in2,i1,i2,i3,start,m,N);%...
% %                                 +Third_order_Mutual_distortion(x_in1,x_in2,x_in2,i2,i1,i3,start,m,N)...
% %                                 +Third_order_Mutual_distortion(x_in1,x_in
% %                                 2,x_in2,i3,i1,i2,start,m,N);
%                    A(:,count)= distortion;
%                    count=count+1;
%                end
%            end
%        end

       for i1=0:M5
           for i2=i1:M5
               for i3=i2:M5
                   for i4=i3:M5
                        for i5=i4:M5
                            distortion= Fifth_order_SingleBand_distortion(x_in1,i1,i2,i3,i4,i5,start,m,N);
                            A(:,count)= distortion;
                            count=count+1;
                        end
                   end
               end
           end
       end
       
       
%         for i1=0:M5
%            for i2=i1:M5
%                for i3=i2:M5
%                    for i4=0:M5
%                         for i5=i4:M5
%                             distortion=  Fifth_order_Mutual_distortion_two_x2(x_in1,x_in1,x_in1,x_in2,x_in2,i1,i2,i3,i4,i5,start,m,N);%...
% %                                         +Fifth_order_Mutual_distortion_two_x2(x_in1,x_in1,x_in1,x_in2,x_in2,i1,i2,i4,i3,i5,start,m,N)...
% %                                         +Fifth_order_Mutual_distortion_two_x2(x_in1,x_in1,x_in1,x_in2,x_in2,i1,i3,i4,i2,i5,start,m,N)...
% %                                         +Fifth_order_Mutual_distortion_two_x2(x_in1,x_in1,x_in1,x_in2,x_in2,i2,i3,i4,i1,i5,start,m,N)...
% %                                         +Fifth_order_Mutual_distortion_two_x2(x_in1,x_in1,x_in1,x_in2,x_in2,i1,i2,i5,i3,i4,start,m,N)...
% %                                         +Fifth_order_Mutual_distortion_two_x2(x_in1,x_in1,x_in1,x_in2,x_in2,i1,i3,i5,i2,i4,start,m,N)...
% %                                         +Fifth_order_Mutual_distortion_two_x2(x_in1,x_in1,x_in1,x_in2,x_in2,i2,i3,i5,i1,i4,start,m,N)...
% %                                         +Fifth_order_Mutual_distortion_two_x2(x_in1,x_in1,x_in1,x_in2,x_in2,i1,i4,i5,i2,i3,start,m,N)...
% %                                         +Fifth_order_Mutual_distortion_two_x2(x_in1,x_in1,x_in1,x_in2,x_in2,i2,i4,i5,i1,i3,start,m,N)...
% %                                         +Fifth_order_Mutual_distortion_two_x2(x_in1,x_in1,x_in1,x_in2,x_in2,i3,i4,i5,i1,i2,start,m,N);
% 
%                             A(:,count)= distortion;
%                             count=count+1;
%                         end
%                    end
%                end
%            end
%         end
       
%         for i1=0:M5
%            for i2=0:M5
%                for i3=i2:M5
%                    for i4=i3:M5
%                         for i5=i4:M5
%                             distortion=  Fifth_order_Mutual_distortion_four_x2(x_in1,x_in2,x_in2,x_in2,x_in2,i1,i2,i3,i4,i5,start,m,N);%...
% %                                         +Fifth_order_Mutual_distortion_four_x2(x_in1,x_in2,x_in2,x_in2,x_in2,i2,i1,i3,i4,i5,start,m,N)...
% %                                         +Fifth_order_Mutual_distortion_four_x2(x_in1,x_in2,x_in2,x_in2,x_in2,i3,i1,i2,i4,i5,start,m,N)...
% %                                         +Fifth_order_Mutual_distortion_four_x2(x_in1,x_in2,x_in2,x_in2,x_in2,i4,i1,i2,i3,i5,start,m,N)...
% %                                         +Fifth_order_Mutual_distortion_four_x2(x_in1,x_in2,x_in2,x_in2,x_in2,i5,i1,i2,i3,i4,start,m,N);
%                         
%                             A(:,count)= distortion;
%                             count=count+1;
%                         end
%                    end
%                end
%            end
%         end

%         %%... order
%         A(:,count)= (abs(x_in1(start:N)).^1);
%         count=count+1;

%         %%1.5 order
%         A(:,count)= x_in1(start:N).*(abs(x_in1(start:N)).^0.5);
%         count=count+1;
%         
%         %%2.5 order
%         A(:,count)= x_in1(start:N).*(abs(x_in1(start:N)).^1.5);
%         count=count+1;
%         
%         %%3.5 order
%         A(:,count)= x_in1(start:N).*(abs(x_in1(start:N)).^2.5);
%         count=count+1;
        
%         %%0.5 order
%         A(:,count)= x_in1(start:N).*(abs(x_in1(start:N)).^(-0.5));
%         count=count+1;

        %%2nd order
        A(:,count)= x_in1(start:N).*abs(x_in1(start:N));
        count=count+1;
        
        %%2nd order with memory
%         A(:,count)= x_in1(start-m:N-m).*abs(x_in1(start-m:N-m));
%         count=count+1;
        
        %%4th order
        A(:,count)= x_in1(start:N).* abs(x_in1(start:N)).^3;
        count=count+1;
        
        %%4th order with memory
%         A(:,count)= x_in1(start-m:N-m).*(abs(x_in1(start-m:N-m)).^3);
%         count=count+1;

        %%6th order
        A(:,count)= x_in1(start:N).*  abs(x_in1(start:N)).^5;
        count=count+1;
        
%        %%7th order
        A(:,count)= x_in1(start:N).*x_in1(start:N).*x_in1(start:N).*x_in1(start:N).*x_in1(start:N).''.*x_in1(start:N).''.*x_in1(start:N).'';
        count=count+1;
%         
        %        %%9th order
        A(:,count)= x_in1(start:N).*x_in1(start:N).*x_in1(start:N).*x_in1(start:N).*x_in1(start:N).*x_in1(start:N).''.*x_in1(start:N).''.*x_in1(start:N).''.*x_in1(start:N).'';
        count=count+1;
% 
% %        %%11th order
%         A(:,count)= x_in1(start:N).*x_in1(start:N).*x_in1(start:N).*x_in1(start:N).*x_in1(start:N).*x_in1(start:N).*x_in1(start:N).''.*x_in1(start:N).''.*x_in1(start:N).''.*x_in1(start:N).''.*x_in1(start:N).'';
%         count=count+1;
% 
% %        %%13th order
%         A(:,count)= x_in1(start:N).*x_in1(start:N).*x_in1(start:N).*x_in1(start:N).*x_in1(start:N).*x_in1(start:N).*x_in1(start:N).*x_in1(start:N).''.*x_in1(start:N).''.*x_in1(start:N).''.*x_in1(start:N).''.*x_in1(start:N).''.*x_in1(start:N).'';
%         count=count+1;
% 
% %        %%15th order
%         A(:,count)= x_in1(start:N).*x_in1(start:N).*x_in1(start:N).*x_in1(start:N).*x_in1(start:N).*x_in1(start:N).*x_in1(start:N).*x_in1(start:N).*x_in1(start:N).''.*x_in1(start:N).''.*x_in1(start:N).''.*x_in1(start:N).''.*x_in1(start:N).''.*x_in1(start:N).''.*x_in1(start:N).'';
%         count=count+1;

end

% % % % 3rd derivation
% % function A=Construct_Volterra_DIDO_model_matrix(x_in1,x_in2,start,m,N,M1,M3,M5)
% %        count=1;
% %        for i1=0:M1
% %            A(:,count)=x_in1(start-i1*m:N-i1*m);
% %            count=count+1;
% %        end
% %        for i1=0:M3
% %            for i2=i1:M3
% %                for i3=i2:M3
% %                    distortion=  Third_order_SingleBand_distortion(x_in1,i1,i2,i3,start,m,N) ;                        
% %                    A(:,count)= distortion;
% %                    count=count+1;
% %                end
% %            end
% %        end
% %        
% %        for i1=0:M3
% %            for i2=i1:M3
% %                for i3=i2:M3
% %                    distortion=   Third_order_Mutual_distortion(x_in1,x_in2,x_in2,i1,i2,i3,start,m,N)...
% %                                 +Third_order_Mutual_distortion(x_in1,x_in2,x_in2,i2,i1,i3,start,m,N)...
% %                                 +Third_order_Mutual_distortion(x_in1,x_in2,x_in2,i3,i1,i2,start,m,N);
% %                    A(:,count)= distortion;
% %                    count=count+1;
% %                end
% %            end
% %        end
% % 
% %        for i1=0:M5
% %            for i2=i1:M5
% %                for i3=i2:M5
% %                    for i4=i3:M5
% %                         for i5=i4:M5
% %                             distortion= Fifth_order_SingleBand_distortion(x_in1,i1,i2,i3,i4,i5,start,m,N);
% %                             A(:,count)= distortion;
% %                             count=count+1;
% %                         end
% %                    end
% %                end
% %            end
% %        end
% %        
% %        
% %         for i1=0:M5
% %            for i2=i1:M5
% %                for i3=i2:M5
% %                    for i4=i3:M5
% %                         for i5=i4:M5
% %                             distortion=  Fifth_order_Mutual_distortion_two_x2(x_in1,x_in1,x_in1,x_in2,x_in2,i1,i2,i3,i4,i5,start,m,N)...
% %                                         +Fifth_order_Mutual_distortion_two_x2(x_in1,x_in1,x_in1,x_in2,x_in2,i1,i2,i4,i3,i5,start,m,N)...
% %                                         +Fifth_order_Mutual_distortion_two_x2(x_in1,x_in1,x_in1,x_in2,x_in2,i1,i3,i4,i2,i5,start,m,N)...
% %                                         +Fifth_order_Mutual_distortion_two_x2(x_in1,x_in1,x_in1,x_in2,x_in2,i2,i3,i4,i1,i5,start,m,N)...
% %                                         +Fifth_order_Mutual_distortion_two_x2(x_in1,x_in1,x_in1,x_in2,x_in2,i1,i2,i5,i3,i4,start,m,N)...
% %                                         +Fifth_order_Mutual_distortion_two_x2(x_in1,x_in1,x_in1,x_in2,x_in2,i1,i3,i5,i2,i4,start,m,N)...
% %                                         +Fifth_order_Mutual_distortion_two_x2(x_in1,x_in1,x_in1,x_in2,x_in2,i2,i3,i5,i1,i4,start,m,N)...
% %                                         +Fifth_order_Mutual_distortion_two_x2(x_in1,x_in1,x_in1,x_in2,x_in2,i1,i4,i5,i2,i3,start,m,N)...
% %                                         +Fifth_order_Mutual_distortion_two_x2(x_in1,x_in1,x_in1,x_in2,x_in2,i2,i4,i5,i1,i3,start,m,N)...
% %                                         +Fifth_order_Mutual_distortion_two_x2(x_in1,x_in1,x_in1,x_in2,x_in2,i3,i4,i5,i1,i2,start,m,N);
% % 
% %                             A(:,count)= distortion;
% %                             count=count+1;
% %                         end
% %                    end
% %                end
% %            end
% %         end
% %        
% %         for i1=0:M5
% %            for i2=i1:M5
% %                for i3=i2:M5
% %                    for i4=i3:M5
% %                         for i5=i4:M5
% %                             distortion=  Fifth_order_Mutual_distortion_four_x2(x_in1,x_in2,x_in2,x_in2,x_in2,i1,i2,i3,i4,i5,start,m,N)...
% %                                         +Fifth_order_Mutual_distortion_four_x2(x_in1,x_in2,x_in2,x_in2,x_in2,i2,i1,i3,i4,i5,start,m,N)...
% %                                         +Fifth_order_Mutual_distortion_four_x2(x_in1,x_in2,x_in2,x_in2,x_in2,i3,i1,i2,i4,i5,start,m,N)...
% %                                         +Fifth_order_Mutual_distortion_four_x2(x_in1,x_in2,x_in2,x_in2,x_in2,i4,i1,i2,i3,i5,start,m,N)...
% %                                         +Fifth_order_Mutual_distortion_four_x2(x_in1,x_in2,x_in2,x_in2,x_in2,i5,i1,i2,i3,i4,start,m,N);
% %                         
% %                             A(:,count)= distortion;
% %                             count=count+1;
% %                         end
% %                    end
% %                end
% %            end
% %        end
% % end
% % 



function distortion=Third_order_SingleBand_distortion(x_in,i1,i2,i3,start,m,N)%x1,x1,x1
    distortion=  x_in(start-i1*m:N-i1*m).*x_in(start-i2*m:N-i2*m).*x_in(start-i3*m:N-i3*m).'' ...
                +x_in(start-i1*m:N-i1*m).*x_in(start-i2*m:N-i2*m).''.*x_in(start-i3*m:N-i3*m) ...
                +x_in(start-i1*m:N-i1*m).''.*x_in(start-i2*m:N-i2*m).*x_in(start-i3*m:N-i3*m);
end

function distortion=Third_order_Mutual_distortion(a,b,c,i1,i2,i3,start,m,N)%x1,x2,x2
    distortion=   a(start-i1*m:N-i1*m).*b(start-i2*m:N-i2*m).*c(start-i3*m:N-i3*m).'' ...
                 +a(start-i1*m:N-i1*m).*b(start-i2*m:N-i2*m).''.*c(start-i3*m:N-i3*m);
end

function distortion=Fifth_order_SingleBand_distortion(x_in,i1,i2,i3,i4,i5,start,m,N)%x1,x1,x1,x1,x1
distortion=  x_in(start-i1*m:N-i1*m).*x_in(start-i2*m:N-i2*m).*x_in(start-i3*m:N-i3*m).*x_in(start-i4*m:N-i4*m).''.*x_in(start-i5*m:N-i5*m).'' ...
            +x_in(start-i1*m:N-i1*m).*x_in(start-i2*m:N-i2*m).*x_in(start-i3*m:N-i3*m).''.*x_in(start-i4*m:N-i4*m).*x_in(start-i5*m:N-i5*m).'' ...
            +x_in(start-i1*m:N-i1*m).*x_in(start-i2*m:N-i2*m).''.*x_in(start-i3*m:N-i3*m).*x_in(start-i4*m:N-i4*m).*x_in(start-i5*m:N-i5*m).'' ...
            +x_in(start-i1*m:N-i1*m).''.*x_in(start-i2*m:N-i2*m).*x_in(start-i3*m:N-i3*m).*x_in(start-i4*m:N-i4*m).*x_in(start-i5*m:N-i5*m).'' ...
            +x_in(start-i1*m:N-i1*m).*x_in(start-i2*m:N-i2*m).*x_in(start-i3*m:N-i3*m).''.*x_in(start-i4*m:N-i4*m).''.*x_in(start-i5*m:N-i5*m) ...
            +x_in(start-i1*m:N-i1*m).*x_in(start-i2*m:N-i2*m).''.*x_in(start-i3*m:N-i3*m).*x_in(start-i4*m:N-i4*m).''.*x_in(start-i5*m:N-i5*m) ...
            +x_in(start-i1*m:N-i1*m).''.*x_in(start-i2*m:N-i2*m).*x_in(start-i3*m:N-i3*m).*x_in(start-i4*m:N-i4*m).''.*x_in(start-i5*m:N-i5*m) ...
            +x_in(start-i1*m:N-i1*m).*x_in(start-i2*m:N-i2*m).''.*x_in(start-i3*m:N-i3*m).''.*x_in(start-i4*m:N-i4*m).*x_in(start-i5*m:N-i5*m) ...
            +x_in(start-i1*m:N-i1*m).''.*x_in(start-i2*m:N-i2*m).*x_in(start-i3*m:N-i3*m).''.*x_in(start-i4*m:N-i4*m).*x_in(start-i5*m:N-i5*m) ...
            +x_in(start-i1*m:N-i1*m).''.*x_in(start-i2*m:N-i2*m).''.*x_in(start-i3*m:N-i3*m).*x_in(start-i4*m:N-i4*m).*x_in(start-i5*m:N-i5*m);
end

function distortion=Fifth_order_Mutual_distortion_two_x2(a,b,c,d,e,i1,i2,i3,i4,i5,start,m,N)%x1,x1,x1,x2,x2
distortion=  a(start-i1*m:N-i1*m).*b(start-i2*m:N-i2*m).*c(start-i3*m:N-i3*m).''.*d(start-i4*m:N-i4*m).*e(start-i5*m:N-i5*m).'' ...
            +a(start-i1*m:N-i1*m).*b(start-i2*m:N-i2*m).''.*c(start-i3*m:N-i3*m).*d(start-i4*m:N-i4*m).*e(start-i5*m:N-i5*m).'' ...
            +a(start-i1*m:N-i1*m).''.*b(start-i2*m:N-i2*m).*c(start-i3*m:N-i3*m).*d(start-i4*m:N-i4*m).*e(start-i5*m:N-i5*m).'' ...
            +a(start-i1*m:N-i1*m).*b(start-i2*m:N-i2*m).*c(start-i3*m:N-i3*m).''.*d(start-i4*m:N-i4*m).''.*e(start-i5*m:N-i5*m) ...
            +a(start-i1*m:N-i1*m).*b(start-i2*m:N-i2*m).''.*c(start-i3*m:N-i3*m).*d(start-i4*m:N-i4*m).''.*e(start-i5*m:N-i5*m) ...
            +a(start-i1*m:N-i1*m).''.*b(start-i2*m:N-i2*m).*c(start-i3*m:N-i3*m).*d(start-i4*m:N-i4*m).''.*e(start-i5*m:N-i5*m) ;
end

function distortion=Fifth_order_Mutual_distortion_four_x2(a,b,c,d,e,i1,i2,i3,i4,i5,start,m,N)%x1,x2,x2,x2,x2
distortion=  a(start-i1*m:N-i1*m).*b(start-i2*m:N-i2*m).*c(start-i3*m:N-i3*m).*d(start-i4*m:N-i4*m).''.*e(start-i5*m:N-i5*m).'' ...
            +a(start-i1*m:N-i1*m).*b(start-i2*m:N-i2*m).*c(start-i3*m:N-i3*m).''.*d(start-i4*m:N-i4*m).*e(start-i5*m:N-i5*m).'' ...
            +a(start-i1*m:N-i1*m).*b(start-i2*m:N-i2*m).''.*c(start-i3*m:N-i3*m).*d(start-i4*m:N-i4*m).*e(start-i5*m:N-i5*m).'' ...
            +a(start-i1*m:N-i1*m).*b(start-i2*m:N-i2*m).*c(start-i3*m:N-i3*m).''.*d(start-i4*m:N-i4*m).''.*e(start-i5*m:N-i5*m) ...
            +a(start-i1*m:N-i1*m).*b(start-i2*m:N-i2*m).''.*c(start-i3*m:N-i3*m).*d(start-i4*m:N-i4*m).''.*e(start-i5*m:N-i5*m) ...
            +a(start-i1*m:N-i1*m).*b(start-i2*m:N-i2*m).''.*c(start-i3*m:N-i3*m).''.*d(start-i4*m:N-i4*m).*e(start-i5*m:N-i5*m);
end

