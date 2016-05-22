x = [0:3];
a = [0.0458 0.0412 0.0497 0.00997];
b = [-0.0619 -0.0599 -0.0289 -0.00168]
ea = 1.96*[0.00751 0.00769 0.00683 0.00249];
eb = 1.96*[0.0110 0.0113 0.0103 0.00367]

figure
hold on;
h1 = errorbar(a,ea,'rx')
h2 = errorbar(b,eb,'rx')
h3 = plot(1:4, a+b,'*')
h1.Color = [254 131 29]/256
h2.Color = [17 152 152]/256
h3.Color = [77 45 115]/256

plot([0 10], [0 0], ':', 'Color', 'black');

legend('Female CESD','Male x CESD', 'Male CESD','Location','southeast')

set(gca,'XTick', 1:4 )
set(gca,'XTickLabel',{'Weight Problems', 'Overweight', 'Obese', 'Morbidly Obese'} );

xlim([0 4.3])



%% export plot
hx = xlabel('');
hy = ylabel('');


% the following code makes the plot look nice and increase font size etc.
set(gca,'fontsize',20,'fontname','Helvetica','box','off','tickdir','out','ticklength',[.02 .02],'xcolor',0.5*[1 1 1],'ycolor',0.5*[1 1 1]);
set([hx; hy],'fontsize',18,'fontname','avantgarde','color',[.3 .3 .3]);
%grid on;

hold off;
w = 10; h = 10;
set(gcf, 'PaperPosition', [0 0 w h]); %Position plot at left hand corner with width w and height h.
set(gcf, 'PaperSize', [w h]); %Set the paper to have width w and height h.
 saveas(gcf, '1', 'pdf') %Save figure
 
 %%
 x = [0:3];
a = [0.0458 0.0412 0.0497 0.00997];
b = [-0.0619 -0.0599 -0.0289 -0.00168]
ea = 1.96*[0.00751 0.00769 0.00683 0.00249];
eb = 1.96*[0.0110 0.0113 0.0103 0.00367]

scale = [68.32 67.27 27.14 2.89]/100;


figure
hold on;
h1 = errorbar(a./scale,ea./scale,'rx')
h2 = errorbar(b./scale,eb./scale,'rx')
h3 = plot(1:4, a./scale+b./scale,'*')
h1.Color = [254 131 29]/256
h2.Color = [17 152 152]/256
h3.Color = [77 45 115]/256

plot([0 10], [0 0], ':', 'Color', 'black');

legend('Female CESD','Male x CESD', 'Male CESD','Location','southeast')

set(gca,'XTick', 1:4 )
set(gca,'XTickLabel',{'Weight Problems', 'Overweight', 'Obese', 'Morbidly Obese'} );

xlim([0 4.3])

%% export plot
hx = xlabel('');
hy = ylabel('');


% the following code makes the plot look nice and increase font size etc.
set(gca,'fontsize',20,'fontname','Helvetica','box','off','tickdir','out','ticklength',[.02 .02],'xcolor',0.5*[1 1 1],'ycolor',0.5*[1 1 1]);
set([hx; hy],'fontsize',18,'fontname','avantgarde','color',[.3 .3 .3]);
%grid on;

hold off;
w = 10; h = 10;
set(gcf, 'PaperPosition', [0 0 w h]); %Position plot at left hand corner with width w and height h.
set(gcf, 'PaperSize', [w h]); %Set the paper to have width w and height h.
 saveas(gcf, '2', 'pdf') %Save figure
 