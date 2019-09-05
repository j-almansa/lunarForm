function summary(X,varname,units,saveflag)
%
fprintf('---[ %s ]------------------------------------\n',varname);
fprintf('nr. of obs: %d\n', length(X));
fprintf('mean: %g %s\n', mean(X,'omitnan'),units);
fprintf('standard deviation: %g %s\n', std(X,'omitnan'),units);



% Boxplot of data
quant = quantile(X,0:0.25:1);
fig1=figure('Name',varname);
boxplot(X,'labels',{varname},'plotstyle','traditional');
hold on;
plot(1,quant(5),'ko','Tag','max','MarkerSize',4,'MarkerFaceColor','k');
plot(1,quant(4),'bo','Tag','q3','MarkerSize',4,'MarkerFaceColor','b');
plot(1,quant(2),'bo','Tag','q1','MarkerSize',4,'MarkerFaceColor','b');
plot(1,quant(1),'ko','Tag','min','MarkerSize',4,'MarkerFaceColor','k');
legend([findobj(gca,'Tag','max'),...
        findobj(gca,'Tag','q3'),...
        findobj(gca,'Tag','Median'),...
        findobj(gca,'Tag','q1'),...
        findobj(gca,'Tag','min')],...
        arrayfun(@num2str, flip(quant), 'unif', 0));
hold off;



% Histogram of data with normal pdf fit
fig2=figure('Name',varname);
histfit(X);
hold on;
color = [0.20784 0.16471 0.52549];
plot(0,0,'s','Tag','mean','MarkerSize',4,'Color',color,'MarkerFaceColor',color,'Visible','off');
plot(0,0,'s','Tag','std','MarkerSize',4,'Color',color,'MarkerFaceColor',color,'Visible','off');
plot(0,0,'s','Tag','skew','MarkerSize',4,'Color',color,'MarkerFaceColor',color,'Visible','off');
plot(0,0,'s','Tag','kurt','MarkerSize',4,'Color',color,'MarkerFaceColor',color,'Visible','off');
legend([findobj(gca,'Tag','mean'),...
        findobj(gca,'Tag','std'),...
        findobj(gca,'Tag','skew'),...
        findobj(gca,'Tag','kurt')],...
       {sprintf('mean:%g ',mean(X,'omitnan')),...
        sprintf('std:%g ',std(X,'omitnan')),...
        sprintf('skew:%g ',skewness(X)),...
        sprintf('kurt:%g ',kurtosis(X))});
hold off;



% Probability plot
%2DO: add lines of upper and lower adjacent values (whiskers's ends)
fig3=figure('Name',varname);
probplot('normal',X);



if strcmp(saveflag,'save')
    fname1 = regexprep(lower( sprintf('../images/%s_boxplot.jpg',varname)  ),'\s+','');
    fname2 = regexprep(lower( sprintf('../images/%s_histfit.jpg',varname)  ),'\s+','');
    fname3 = regexprep(lower( sprintf('../images/%s_probplot.jpg',varname)  ),'\s+','');
    saveas(fig1,fname1);
    saveas(fig2,fname2);
    saveas(fig3,fname3);
end
