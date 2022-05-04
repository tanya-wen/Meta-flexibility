function [tval,adj_p] = comparisons_between_bars(xx, cond_vals)

% xx = xticks (e.g., xx = [1,2,3,4,5,6])
% cond_vals = all subject values within each condition


%% perform t-test on each pairwise condition
pcount = 1;
for a1 = xx
    for a2 = xx
        if a1<a2
            [h,pvalues(pcount),ci, stats] = ttest(cond_vals(:,a1),cond_vals(:,a2));
            tval(pcount) = stats.tstat;
            pcount = pcount + 1;
        end
    end
end


%% correct for multiple comparisons
[h, crit_p, adj_ci_cvrg, adj_p]=fdr_bh(pvalues,0.05);


%% plot out lines and asterisks for significant pairs
pcount = 1;
count = 0;
for a1 = xx
    for a2 = xx
        if a1<a2
            
            bar_input = mean(cond_vals);
            ymax = max(bar_input); ymin = min(bar_input);
            
            if adj_p(pcount) < 0.05
                count = count + 1/3*(ymax-ymin);
                line([xx(a1),xx(a2)],[ymax+(count),ymax+(count)],'Color','k');
                if adj_p(pcount) < 0.001
                    text((xx(a1)+xx(a2))/2,ymax+(count), sprintf('*** %.2f',tval(pcount)),'HorizontalAlignment','center');
                elseif adj_p(pcount) < 0.01
                    text((xx(a1)+xx(a2))/2,ymax+(count), sprintf('** %.2f',tval(pcount)),'HorizontalAlignment','center');
                else text((xx(a1)+xx(a2))/2,ymax+(count), sprintf('* %.2f',tval(pcount)),'HorizontalAlignment','center');
                end
            end
            
            pcount = pcount + 1;
            xlim([min(xx)-1,max(xx)+1]);
        end
    end
end



end