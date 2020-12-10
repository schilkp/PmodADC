classdef ProgressUpdate < handle
   properties
       n_steps
       percent_step
       last_report
   end
   methods
      function obj = ProgressUpdate(n_steps, percent_step)
         if nargin == 2
            obj.n_steps = n_steps;
            obj.percent_step = percent_step;
            obj.last_report = -inf;
         else
            ME = MException('ProgressUpdate:Setup', 'Needs 2 Variables');
            throw(ME)
         end
      end
      
      function Update(obj,current_step)
          percent = round(current_step/obj.n_steps*100);
          if percent >= obj.last_report+obj.percent_step
             obj.last_report = percent;
             disp([num2str(percent),'%, ',num2str(current_step),'/',num2str(obj.n_steps)]);
          end
      end
   end
end