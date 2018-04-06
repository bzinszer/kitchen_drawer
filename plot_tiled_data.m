function plot_tiled_data(data_array,type,titletext,xlabtext)

%% Configure for plotting the channels
display_dims = get(0,'MonitorPosition');
num_panels = size(data_array,ndims(data_array));

% If multiple displays, select primary display
if size(display_dims,1)>1, display_dims = display_dims(1,:); end

% Figure out the best-ish vertical-to-horizontal ratio to lay out the 
% subplots based on the size of the display
vert_tiles = ceil(sqrt(num_panels / (display_dims(3)/display_dims(4))));
horiz_tiles = ceil(num_panels / vert_tiles);


switch type
    case 'bar'
        myplot=@(plotdat) bar(plotdat);
    case 'dot'
        myplot=@(plotdat) plot(plotdat,'o');
    case 'hist'
        myplot=@(plotdat) hist(plotdat);
    case 'imagesc'
        myplot=@(plotdat) imagesc(plotdat); colormap('hot');
    otherwise
        myplot=@(plotdat) plot(plotdat);
end

% Iterate over the last dimension of the data_array
for curr_panel = 1:size(data_array,ndims(data_array));
    subplot(vert_tiles,horiz_tiles,curr_panel)
    not_last_dims = repmat({':'},1,ndims(data_array)-1);
    myplot(data_array(not_last_dims{:},curr_panel))
    title(sprintf('%s #%g',titletext,curr_panel))
    xlabel(xlabtext)
    %ylim([min(data_array(:)) max(data_array(:))]);
    %xlim([0 size(data_array,1)]);
end
